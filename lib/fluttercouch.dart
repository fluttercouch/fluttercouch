export 'document.dart';
export 'mutable_document.dart';
export 'listener_token.dart';
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
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:fluttercouch/document.dart';

import 'blob.dart';

abstract class Fluttercouch {
  static const MethodChannel _methodChannel =
      const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  static const EventChannel _replicationEventChannel = const EventChannel(
      "it.oltrenuovefrontiere.fluttercouch/replicationEventChannel");

  Stream _replicationStream = _replicationEventChannel.receiveBroadcastStream();

  Future<String> initDatabaseWithName(String _name) =>
      _methodChannel.invokeMethod('initDatabaseWithName', _name);

  Future<String> saveDocument(Document _doc) {
    if (_doc.attachments == null || _doc.attachments.isEmpty) {
      return _methodChannel.invokeMethod('saveDocument', _doc.toMap());
    } else {
      return _methodChannel.invokeMethod('saveDocumentWithBlobs',
          <String, dynamic>{'map': _doc.toMap(), 'blobs': _doc.attachments});
    }
  }

  Future<String> saveDocumentWithId(String _id, Document _doc) {
    if (_doc.attachments == null || _doc.attachments.isEmpty) {
      return _methodChannel.invokeMethod('saveDocumentWithId',
          <String, dynamic>{'id': _id, 'map': _doc.toMap()});
    } else {
      return _methodChannel.invokeMethod(
          'saveDocumentWithIdAndBlobs', <String, dynamic>{
        'id': _id,
        'map': _doc.toMap(),
        'blobs': _doc.attachments
      });
    }
  }

  Future<Blob> getAttachment(String _docId, String _attachmentName) {
    return getBlob(_docId, _attachmentName);
  }

  Future<Blob> getBlob(String _docId, String _blobName) async {
    Blob b;
    Map<String, Uint8List> blobData = Map();
    Map<dynamic, dynamic> data = await _methodChannel.invokeMethod(
        'getBlob', <String, dynamic>{'id': _docId, 'blobName': _blobName});

    data.forEach((key, value) {
      blobData[key as String] = value as Uint8List;
    });

    blobData.forEach((contentType, data) {
      b = Blob(_blobName, contentType, data);
    });

    return b;
  }

  Future<Document> getDocumentWithId(String _id) async {
    Map<dynamic, dynamic> _docResult;
    _docResult = await _methodChannel.invokeMethod('getDocumentWithId', _id);
    return Document(_docResult["doc"], _docResult["id"]);
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

  Future<String> closeDatabaseWithName(String _name) =>
      _methodChannel.invokeMethod('closeDatabaseWithName', _name);

  Future<String> closeDatabase() =>
      _methodChannel.invokeMethod('closeDatabase');

  Future<Null> deleteDatabaseWithName(String _name) =>
      _methodChannel.invokeMethod('deleteDatabaseWithName', _name);

  Future<int> getDocumentCount() =>
      _methodChannel.invokeMethod('getDocumentCount');

  StreamSubscription listenReplicationEvents(Function(String) function) {
    return _replicationStream.listen(function);
  }
}
