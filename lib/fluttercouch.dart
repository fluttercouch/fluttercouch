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
import 'dart:core';

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
import 'replication/replicator_configuration.dart';

typedef DocumentChangeListener = void Function(DocumentChange change);
typedef ConflictHandler = bool Function(
    MutableDocument newDoc, Document curdoc);

class Fluttercouch {
  static final Fluttercouch _fluttercouch = Fluttercouch._internal();

  factory Fluttercouch() {
    if (!_fluttercouch._methodChannel
        .checkMethodCallHandler(_fluttercouch.nativeCallHandler)) {
      _fluttercouch._methodChannel
          .setMethodCallHandler(_fluttercouch.nativeCallHandler);
    }
    _fluttercouch._eventsStream =
        _fluttercouch.eventChannel.receiveBroadcastStream();
    _fluttercouch._eventsStream
        .listen(_fluttercouch._onEvent, onError: _fluttercouch._onEventError);
    return _fluttercouch;
  }

  Fluttercouch._internal();

  final MethodChannel _methodChannel =
      const MethodChannel('dev.lucachristille.fluttercouch/methodChannel');

  final EventChannel eventChannel =
      const EventChannel("dev.lucachristille.fluttercouch/eventsChannel");

  Stream _eventsStream;

  final Map<String, Database> _databases = new Map();
  final Map<String, ConflictHandler> _conflictHandlers = new Map();
  final Map<String, Exception> _exceptionsRethrowing = new Map();
  final Map<String, Replicator> _replicators = new Map();
  final Map<String, ConflictResolver> _conflictResolvers = new Map();
  final Map<String, ReplicationFilter> _replicationFilters = new Map();
  final Map<String, DocumentChangeListener> _documentChangeListeners =
      new Map();
  final Map<String, ReplicatorChangeListener> _replicatorChangeListeners =
      new Map();
  final Map<String, DocumentReplicationListener> _documentReplicationListeners =
      new Map();

  Future<Map<String, String>> initDatabaseWithName(String _name,
      {DatabaseConfiguration configuration}) async {
    String directory;
    if (configuration != null) {
      directory = configuration.getDirectory();
    }
    return _methodChannel.invokeMapMethod<String, String>(
        'initDatabaseWithName', {"dbName": _name, "directory": directory});
  }

  _onEvent(dynamic data) {
    Map<String, String> event =
        Map.castFrom<dynamic, dynamic, String, String>(data);
    if (event.containsKey("type")) {
      switch (event["type"]) {
        case "document_change_event":
          DocumentChange change = DocumentChange();
          change._database = getRegisteredDatabase(event["database"]);
          change._documentID = event["documentID"];
          DocumentChangeListener documentChangeListener =
              _documentChangeListeners[event["listenerToken"]];
          if (documentChangeListener != null) {
            documentChangeListener(change);
          }
          break;
      }
    }
    event = event;
  }

  _onEventError(Object error) {}

  Future<String> saveDocument(Document doc, String dbName) =>
      _methodChannel.invokeMethod('saveDocument',
          <String, dynamic>{'doc': doc.toMap(), 'dbName': dbName});

  Future<Null> saveDocumentWithId(String id, Document doc, String dbName) =>
      _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'id': id, 'map': doc.toMap(), 'dbName': dbName});

  Future<bool> saveDocumentWithIdAndConcurrencyControl(String id, Document doc,
      ConcurrencyControl concurrencyControl, String dbName) {
    String concurrencyControlString;
    if (concurrencyControl == ConcurrencyControl.FAIL_ON_CONFLICT) {
      concurrencyControlString = "FAIL_ON_CONFLICT";
    } else if (concurrencyControl == ConcurrencyControl.LAST_WRITE_WINS) {
      concurrencyControlString = "LAST_WRITE_WINS";
    }
    return _methodChannel.invokeMethod(
        'saveDocumentWithIdAndConcurrencyControl', <String, dynamic>{
      'id': id,
      'map': doc.toMap(),
      'concurrencyControl': concurrencyControlString,
      'dbName': dbName
    });
  }

  Future<bool> saveDocumentWithIdAndConflictHandler(String _id, Document _doc,
      ConflictHandler conflictHandler, String dbName) async {
    String uuid =
        new Uuid().v5(dbName + "::" + "customer_conflict_handler", _id);
    _conflictHandlers[uuid] = conflictHandler;
    var result = await _methodChannel.invokeMethod(
        'saveDocumentWithIdAndConcurrencyControl', <String, dynamic>{
      'id': _id,
      'map': _doc.toMap(),
      'conflictHandlerUUID': uuid
    });
    _conflictHandlers.remove(uuid);
    return result;
  }

  Future<Document> getDocumentWithId(String id, String dbName) async {
    Map<dynamic, dynamic> _docResult;
    _docResult = await _methodChannel
        .invokeMethod('getDocumentWithId', {"id": id, "dbName": dbName});
    if (_docResult.length == 0) {
      return null;
    } else {
      return Document(_docResult["doc"], _docResult["id"]);
    }
  }

  Future<dynamic> nativeCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "invoke_document_conflict_resolver":
        Map<String, dynamic> result;
        Map<String, dynamic> arguments =
            Map.castFrom<dynamic, dynamic, String, dynamic>(
                methodCall.arguments);
        String uuid = arguments["uuid"];
        MutableDocument newDoc = MutableDocument(
            withID: arguments["id"], state: arguments["newDoc"]);
        Document curDoc = Document(arguments["curDoc"], arguments["id"]);
        ConflictHandler conflictHandler = _conflictHandlers[uuid];
        try {
          result["returnValue"] =
              conflictHandler(newDoc, curDoc) ? "true" : "false";
          result["id"] = arguments["id"];
          result["newDoc"] = newDoc.toMap();
        } catch (e) {
          _exceptionsRethrowing[arguments["uuid"]] = e;
          result["returnValue"] = "exception";
        }
        return result;
      default:
        throw MissingPluginException("notImplemented");
    }
  }

  Future<Null> deleteDocument(String id, String dbName) {
    return _methodChannel
        .invokeMethod("deleteDocument", {"id": id, "dbName": dbName});
  }

  Future<Null> setReplAuthenticator(String uuid, Authenticator authenticator) {
    if (authenticator is BasicAuthenticator) {
      return _methodChannel
          .invokeMethod('setReplicatorBasicAuthentication', <String, dynamic>{
        "uuid": uuid,
        "username": authenticator.getUsername(),
        "password": authenticator.getPassword()
      });
    }
    if (authenticator is SessionAuthenticator) {
      return _methodChannel
          .invokeMethod('setReplicatorSessionAuthentication', <String, dynamic>{
        "uuid": uuid,
        "sessionID": authenticator.getSessionID(),
        "getCookieName": authenticator.getCookieName()
      });
    }
    return null;
  }

  Future<Null> setReplChannels(String uuid, List<String> channels) {
    return _methodChannel.invokeMethod('setReplChannels',
        <String, dynamic>{"uuid": uuid, "channels": channels});
  }

  Future<Null> setReplDocumentsIDs(String uuid, List<String> documentIDs) {
    return _methodChannel.invokeMethod('setReplDocumentsIDs',
        <String, dynamic>{"uuid": uuid, "documentIDs": documentIDs});
  }

  Future<Null> setReplHeaders(String uuid, Map<String, String> headers) {
    return _methodChannel.invokeMethod(
        'setReplHeaders', <String, dynamic>{"uuid": uuid, "headers": headers});
  }

  Future<Null> setReplType(String uuid, ReplicatorType type) {
    return _methodChannel.invokeMethod('setReplType',
        <String, dynamic>{"uuid": uuid, "type": type.toString()});
  }

  Future<Null> setReplContinuous(String uuid, bool continuous) {
    return _methodChannel.invokeMethod('setReplContinuous',
        <String, dynamic>{"uuid": uuid, "continuous": continuous});
  }

  Future<String> constructReplicatorConfiguration(
      String uuid, Database database, Endpoint endpoint) {
    if (endpoint is URLEndpoint) {
      return _methodChannel
          .invokeMethod('constructReplicatorConfiguration', <String, dynamic>{
        "uuid": uuid,
        "dbName": database.getName(),
        "endpointType": "urlEndpoint",
        "endpointConfig": {"uri": endpoint.getURL()}
      });
    } else {
      return null;
    }
  }

  Future<String> constructReplicator(String uuid) {
    return _methodChannel
        .invokeMethod("constructReplicator", <String, String>{"uuid": uuid});
  }

  Future<Null> setReplConflictResolver(String uuid) {
    return _methodChannel
        .invokeMethod('setReplConflictResolver', <String, dynamic>{
      "uuid": uuid,
    });
  }

  Future<Null> setReplPullFilter(String uuid) {
    return _methodChannel.invokeMethod('setReplPullFilter', <String, dynamic>{
      "uuid": uuid,
    });
  }

  Future<Null> setReplPushFilter(String uuid) {
    return _methodChannel.invokeMethod('setReplPushFilter', <String, dynamic>{
      "uuid": uuid,
    });
  }

  Future<String> closeDatabase(String dbName) =>
      _methodChannel.invokeMethod('closeDatabaseWithName', dbName);

  Future<Null> deleteDatabase(String dbName) =>
      _methodChannel.invokeMethod('deleteDatabaseWithName', dbName);

  Future<Null> compactDatabase(String dbName) =>
      _methodChannel.invokeMethod("compactDatabase", dbName);

  Future<int> getDocumentCount({String dbName}) =>
      _methodChannel.invokeMethod('getDocumentCount', {"name": dbName});

  Future<Null> addReplicatorChangeListener(
      String replicatorUuid, String replicatorChangeListenerUuid) {
    return _methodChannel
        .invokeMethod('addReplicatorChangeListener', <String, String>{
      "replicatorUuid": replicatorUuid,
      "replicatorChangeListenerUuid": replicatorChangeListenerUuid
    });
  }

  Future<String> addDocumentChangeListener(String id, String token,
      {String dbName}) {
    return _methodChannel.invokeMethod("setDocumentChangeListener",
        {"id": id, "dbName": dbName, "token": token});
  }

  Future<Null> setDocumentExpirationOfDB(String id, DateTime expiration,
      {String dbName}) {
    return _methodChannel.invokeMethod("setDocumentExpiration", {
      "id": id,
      "expiration": expiration.toIso8601String(),
      "dbName": dbName
    });
  }

  Future<String> getDocumentExpirationOfDB(String id, {String dbName}) {
    return _methodChannel
        .invokeMethod("getDocumentExpiration", {"id": id, "dbName": dbName});
  }

  registerDatabase(String name, Database database) {
    _databases[name] = database;
  }

  registerReplicator(String replicatorUuid, Replicator replicator) {
    _replicators[replicatorUuid] = replicator;
  }

  String registerReplicatorChangeListener(
      ReplicatorChangeListener replicatorChangeListener) {
    String replicatorChangeListenerUuid = new Uuid().v1();
    _replicatorChangeListeners[replicatorChangeListenerUuid] =
        replicatorChangeListener;
    return replicatorChangeListenerUuid;
  }

  unregisterReplicatorChangeListener(String uuid) {
    if (_replicatorChangeListeners.containsKey(uuid)) {
      _replicatorChangeListeners.remove(uuid);
    }
  }

  String registerDocumentChangeListener(DocumentChangeListener changeListener) {
    String changeListenerUuid = new Uuid().v1();
    _documentChangeListeners[changeListenerUuid] = changeListener;
    return changeListenerUuid;
  }

  String registerDocumentReplicationListener(
      DocumentReplicationListener replicationListener) {
    String replicationListenerUuid = new Uuid().v1();
    _documentReplicationListeners[replicationListenerUuid] =
        replicationListener;
    return replicationListenerUuid;
  }

  unregisterDocumentReplicationListener(String uuid) {
    if (_documentReplicationListeners.containsKey(uuid)) {
      _documentReplicationListeners.remove(uuid);
    }
  }

  String registerConflictResolver(ConflictResolver conflictResolver) {
    String conflictResolverUuid = new Uuid().v1();
    _conflictResolvers[conflictResolverUuid] = conflictResolver;
    return conflictResolverUuid;
  }

  String registerReplicationFilter(ReplicationFilter replicationFilter) {
    String replicationFilterUuid = new Uuid().v1();
    _replicationFilters[replicationFilterUuid] = replicationFilter;
    return replicationFilterUuid;
  }

  Database getRegisteredDatabase(String name) {
    if (_databases.containsKey(name)) {
      return _databases[name];
    } else {
      return null;
    }
  }

  Replicator getRegisteredReplicator(String uuid) {
    if (_replicators.containsKey(uuid)) {
      return _replicators[uuid];
    } else {
      return null;
    }
  }
}

class DatabaseChange {
  Database _database;
  List<String> _documentIDs;

  Database getDatabase() {
    return this._database;
  }

  List<String> getDocumentIDs() {
    return this._documentIDs;
  }
}

class DocumentChange {
  Database _database;
  String _documentID;

  Database getDatabase() {
    return this._database;
  }

  String getDocumentID() {
    return this._documentID;
  }
}

enum ConcurrencyControl { FAIL_ON_CONFLICT, LAST_WRITE_WINS }
