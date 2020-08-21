export 'database.dart';
export 'document.dart';
export 'mutable_document.dart';
export 'query/query.dart';
export 'query/from.dart';
export 'query/functions.dart';
export 'query/group_by.dart';
export 'query/having.dart';
export 'query/join.dart';
export 'query/joins.dart';
export 'query/limit.dart';
export 'query/order_by.dart';
export 'query/ordering.dart';
export 'query/parameters.dart';
export 'query/query_builder.dart';
export 'query/result_set.dart';
export 'query/result.dart';
export 'query/select_result.dart';
export 'query/select.dart';
export 'query/where.dart';
export 'query/expression/expression.dart';
export 'query/expression/meta.dart';
export 'query/expression/meta_expression.dart';
export 'query/expression/meta.dart';
export 'query/expression/property_expression.dart';
export 'query/expression/variable_expression.dart';
export 'replication/replicator.dart';
export 'replication/authenticator.dart';
export 'replication/basic_authenticator.dart';
export 'replication/conflict.dart';
export 'replication/document_replication.dart';
export 'replication/endpoint.dart';
export 'replication/replicator_change.dart';
export 'replication/replicator_configuration.dart';
export 'replication/session_authenticator.dart';
export 'replication/status.dart';
export 'replication/url_endpoint.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercouch/database.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/mutable_document.dart';
import 'package:fluttercouch/replication/basic_authenticator.dart';
import 'package:fluttercouch/replication/session_authenticator.dart';
import 'package:fluttercouch/replication/url_endpoint.dart';
import 'package:uuid/uuid.dart';

import 'replication/authenticator.dart';
import 'replication/endpoint.dart';
import 'replication/replicator.dart';

typedef DocumentChangeListener = void Function(DocumentChange change);
typedef ConflictHandler = bool Function(MutableDocument newDoc, Document curdoc);

class Fluttercouch {
  static const MethodChannel _methodChannel =
  const MethodChannel('dev.lucachristille.fluttercouch/methodChannel');

  static const EventChannel eventChannel = const EventChannel(
      "dev.lucachristille.fluttercouch/eventsChannel");

  static Map<String, Database> _databases = new Map();
  static Map<String, ConflictHandler> _conflictHandlers = new Map();
  static Map<String, Exception> _exceptionsRethrowing = new Map();
  static Map<String, Replicator> _replicators = new Map();

  Future<Map<String, String>> initDatabaseWithName(String _name, {DatabaseConfiguration configuration}) async {
    String directory;
    if (configuration != null) {
      directory = configuration.getDirectory();
    }
    return _methodChannel.invokeMapMethod<String, String>('initDatabaseWithName', {
      "dbName": _name,
      "directory": directory
    });
  }

  Future<Null> saveDocument(Document _doc) =>
      _methodChannel.invokeMethod('saveDocument', _doc.toMap());

  Future<Null> saveDocumentWithId(String _id, Document _doc) =>
      _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'id': _id, 'map': _doc.toMap()});

  Future<bool> saveDocumentWithIdAndConcurrencyControl(String _id, Document _doc, ConcurrencyControl concurrencyControl) {
    String concurrencyControlString;
    if (concurrencyControl == ConcurrencyControl.FAIL_ON_CONFLICT) {
      concurrencyControlString = "FAIL_ON_CONFLICT";
    } else if (concurrencyControl == ConcurrencyControl.LAST_WRITE_WINS) {
      concurrencyControlString = "LAST_WRITE_WINS";
    }
    return _methodChannel.invokeMethod('saveDocumentWithIdAndConcurrencyControl',
    <String, dynamic>{'id': _id, 'map': _doc.toMap(), 'concurrencyControl': concurrencyControlString});
  }

  Future<bool> saveDocumentWithIdAndConflictHandler(String _id, Document _doc, ConflictHandler conflictHandler, {String databaseName}) async {
    String uuid = new Uuid().v5(databaseName + "::" + "customer_conflict_handler", _id);
    Fluttercouch._conflictHandlers[uuid] = conflictHandler;
    var result = await _methodChannel.invokeMethod('saveDocumentWithIdAndConcurrencyControl',
        <String, dynamic>{'id': _id, 'map': _doc.toMap(), 'conflictHandlerUUID': uuid});
    Fluttercouch._conflictHandlers.remove(uuid);
    return result;
  }

  Future<Document> getDocumentWithId(String _id, {String dbName}) async {
    Map<dynamic, dynamic> _docResult;
    _docResult = await _methodChannel.invokeMethod('getDocumentWithId', {
      "id": _id,
      "dbName": dbName
    });
    if (_docResult.length == 0) {
      return null;
    } else {
      return Document(_docResult["doc"], _docResult["id"]);
    }
  }

  static Future<dynamic> nativeCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "invoke_document_conflict_resolver":
        Map<String, dynamic> result;
        Map<String, dynamic> arguments = Map.castFrom<dynamic, dynamic, String, dynamic>(methodCall.arguments);
        String uuid = arguments["uuid"];
        MutableDocument newDoc = MutableDocument(withID: arguments["id"], state: arguments["newDoc"]);
        Document curDoc = Document(arguments["curDoc"], arguments["id"]);
        ConflictHandler conflictHandler = Fluttercouch._conflictHandlers[uuid];
        try {
          result["returnValue"] = conflictHandler(newDoc, curDoc) ? "true" : "false";
          result["id"] = arguments["id"];
          result["newDoc"] = newDoc.toMap();
        } catch (e) {
          Fluttercouch._exceptionsRethrowing[arguments["uuid"]] = e;
          result["returnValue"] = "exception";
        }
        return result;
      default:
        throw MissingPluginException("notImplemented");
    }
  }

  Future<Null> deleteDocument(String _id, {String dbName}) {
    return _methodChannel.invokeMethod("deleteDocument", {
      "id": _id,
      "dbName": dbName
    });
  }

  Future<Null> setReplicatorEndpoint(String _endpoint) =>
      _methodChannel.invokeMethod('setReplicatorEndpoint', _endpoint);

  Future<Null> setReplicatorType(String _type) =>
      _methodChannel.invokeMethod('setReplicatorType', _type);

  Future<Null> setReplicatorContinuous(bool _continuous) =>
      _methodChannel.invokeMethod('setReplicatorContinuous', _continuous);

  Future<Null> setReplicatorBasicAuthentication(Map<String, String> _auth) =>
      _methodChannel.invokeMethod('setReplicatorBasicAuthentication', _auth);

  Future<Null> setReplicatorSessionAuthentication(String _sessionID) =>
      _methodChannel.invokeMethod(
          'setReplicatorSessionAuthentication', _sessionID);

  Future<Null> setReplicatorPinnedServerCertificate(String _assetKey) =>
      _methodChannel.invokeMethod(
          'setReplicatorPinnedServerCertificate', _assetKey);

  Future<Null> setReplicatorAuthenticator(String _uuid, Authenticator authenticator) {
    if (authenticator is BasicAuthenticator) {
      return _methodChannel.invokeMethod('setReplicatorBasicAuthentication', <String, String>{
        "uuid": _uuid,
        "username": authenticator.getUsername(),
        "password": authenticator.getPassword()
      });
    }
    if (authenticator is SessionAuthenticator) {
      return _methodChannel.invokeMethod('setReplicatorSessionAuthentication', <String, String>{
        "uuid": _uuid,
        "sessionID": authenticator.getSessionID(),
        "getCookieName": authenticator.getCookieName()
      });
    }
    return null;
  }
  
  Future<Null> setReplicatorChannels(String _uuid, List<String> channels) {
    return _methodChannel.invokeMethod('setReplicatorChannels', <String, dynamic>{
      "uuid": _uuid,
      "channels": channels
    });
  }

  Future<String> constructReplicatorConfiguration(String uuid, Database database, Endpoint endpoint) {
    if (endpoint is URLEndpoint) {
      return _methodChannel.invokeMethod(
          'constructReplicatorConfiguration', <String, String>{
        "uuid": uuid,
        "dbName": database.getName(),
        "endpointType": "urlendpoint",
        "endpointConfig": endpoint.getURL()
      }
      );
    }
  }

  Future<Null> initReplicator() =>
      _methodChannel.invokeMethod("initReplicator");

  Future<Null> startReplicator() =>
      _methodChannel.invokeMethod('startReplicator');

  Future<Null> stopReplicator() =>
      _methodChannel.invokeMethod('stopReplicator');

  Future<String> closeDatabaseWithName(String dbName) =>
      _methodChannel.invokeMethod('closeDatabaseWithName', dbName);

  Future<String> closeDatabase() =>
      _methodChannel.invokeMethod('closeDatabase');

  Future<Null> deleteDatabaseWithName(String dbName) =>
      _methodChannel.invokeMethod('deleteDatabaseWithName', dbName);

  Future<Null> compactDatabaseWithName(String dbName) =>
    _methodChannel.invokeMethod("compactDatabase", dbName);

  Future<int> getDocumentCount({String dbName}) =>
      _methodChannel.invokeMethod('getDocumentCount', { "name": dbName });

  Future<String> registerDocumentChangeListener(String id, String token, {String dbName}) {
    return _methodChannel.invokeMethod("registerDocumentChangeListener", {
      "id": id,
      "dbName": dbName,
      "token": token
    });
  }

  Future<Null> setDocumentExpirationOfDB(String id, DateTime expiration, {String dbName}) {
    return _methodChannel.invokeMethod("setDocumentExpiration", {
      "id": id,
      "expiration": expiration.toIso8601String(),
      "dbName": dbName
    });
  }

  Future<String> getDocumentExpirationOfDB(String id, {String dbName}) {
    return _methodChannel.invokeMethod("getDocumentExpiration", {
      "id": id,
      "dbName": dbName
    });
  }

  static registerDatabase(String name, Database database) {
    _databases[name] = database;
  }

  static registerReplicator(String uuid, Replicator replicator) {
    _replicators[uuid] = replicator;
  }

  static Database getRegisteredDatabase(String name) {
    if (_databases.containsKey(name)) {
      return _databases[name];
    } else {
      return null;
    }
  }

  static Replicator getRegisteredReplicator(String uuid) {
    if (_replicators.containsKey(uuid)) {
      return _replicators[uuid];
    } else {
      return null;
    }
  }

  static initMethodCallHandler() {
    if (!_methodChannel.checkMethodCallHandler(nativeCallHandler)) {
      _methodChannel.setMethodCallHandler(nativeCallHandler);
    }
  }
}
