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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercouch/database.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/listener_token.dart';
import 'package:fluttercouch/mutable_document.dart';

typedef DocumentChangeListener = void Function(DocumentChange change);
typedef ConflictHandler = bool Function(MutableDocument newDoc, Document curdoc);

class Fluttercouch {
  static const MethodChannel _methodChannel =
  const MethodChannel('dev.lucachristille.fluttercouch/methodChannel');

  static const EventChannel eventChannel = const EventChannel(
      "dev.lucachristille.fluttercouch/eventsChannel");

  static Map<String, Database> _databases = new Map();

  Future<Map<String, String>> initDatabaseWithName(String _name, {DatabaseConfiguration configuration}) async {
    String directory = null;
    if (configuration != null) {
      directory = configuration.getDirectory();
    }
    return _methodChannel.invokeMapMethod<String, String>('initDatabaseWithName', {
      "dbName": _name,
      "directory": directory
    });
  }

  Future<String> saveDocument(Document _doc) =>
      _methodChannel.invokeMethod('saveDocument', _doc.toMap());

  Future<String> saveDocumentWithId(String _id, Document _doc) =>
      _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'id': _id, 'map': _doc.toMap()});

  Future<String> saveDocumentWithIdAndConcurrencyControl(String _id, Document _doc, ConcurrencyControl concurrencyControl) {
    String concurrencyControlString;
    if (concurrencyControl == ConcurrencyControl.FAIL_ON_CONFLICT) {
      concurrencyControlString = "FAIL_ON_CONFLICT";
    } else if (concurrencyControl == ConcurrencyControl.LAST_WRITE_WINS) {
      concurrencyControlString = "LAST_WRITE_WINS";
    }
    return _methodChannel.invokeMethod('saveDocumentWithIdAndConcurrencyControl',
    <String, dynamic>{'id': _id, 'map': _doc.toMap(), 'concurrencyControl': concurrencyControlString});
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
        return false;
      default:
        throw MissingPluginException("notImplemented");
    }
  }

  Future<Null> deleteDocument(String _id, {String dbName}) {
    _methodChannel.invokeMethod("deleteDocument", {
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

  static Database getRegisteredDatabase(String name) {
    if (_databases.containsKey(name)) {
      return _databases[name];
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
