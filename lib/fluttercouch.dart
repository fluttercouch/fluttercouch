import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercouch/document.dart';

abstract class Fluttercouch {
  static const MethodChannel _methodChannel =
      const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  static const EventChannel _replicationEventChannel =
    const EventChannel("it.oltrenuovefrontiere.fluttercouch/replicationEventChannel");

  Future<String> initDatabaseWithName(String _name) async {
    try {
      final String result =
          await _methodChannel.invokeMethod('initDatabaseWithName', _name);
      return result;
    } on PlatformException catch (e) {
      throw 'unable to init database $_name: ${e.message}';
    }
  }

  Future<String> saveDocument(Document _doc) async {
    try {
      final String result = await _methodChannel.invokeMethod('saveDocument', _doc.toMap());
      return result;
    } on PlatformException {
      throw 'unable to save the document';
    }
  }

  Future<String> saveDocumentWithId(String _id, Document _doc) async {
    try {
      final String result = await _methodChannel.invokeMethod(
          'saveDocumentWithId', <String, dynamic>{'id': _id, 'map': _doc.toMap()});
      return result;
    } on PlatformException {
      throw 'unable to save the document with set id $_id';
    }
  }

  Future<Document> getDocumentWithId(String _id) async {
    Map<dynamic, dynamic> _docResult;
    _docResult = await _getDocumentWithId(_id);
    return Document(_docResult["doc"], _docResult["id"]);
  }

  Future<String> setReplicatorEndpoint(String _endpoint) async {
    try {
      final String result =
          await _methodChannel.invokeMethod('setReplicatorEndpoint', _endpoint);
      return result;
    } on PlatformException {
      throw 'unable to set target endpoint to $_endpoint';
    }
  }

  Future<String> setReplicatorType(String _type) async {
    try {
      final String result =
          await _methodChannel.invokeMethod('setReplicatorType', _type);
      return result;
    } on PlatformException {
      throw 'unable to set replicator type to $_type';
    }
  }

  Future<bool> setReplicatorContinuous(bool _continuous) async {
    try {
      final bool result = await _methodChannel.invokeMethod('setReplicatorContinuous', _continuous);
      return result;
    } on PlatformException {
      throw 'unable to set replicator continuous setting to $_continuous';
    }
  }

  Future<String> setReplicatorBasicAuthentication(
      Map<String, String> _auth) async {
    try {
      final String result = await _methodChannel.invokeMethod(
          'setReplicatorBasicAuthentication', _auth);
      return result;
    } on PlatformException {
      throw 'unable to set replicator basic authentication';
    }
  }

  Future<String> setReplicatorSessionAuthentication(String _sessionID) async {
    try {
      final String result = await _methodChannel.invokeMethod('setReplicatorSessionAuthentication', _sessionID);
      return result;
    } on PlatformException {
      throw 'unable to set replicator basic authentication';
    }
  }

  Future<Null> initReplicator() async {
    try {
      await _methodChannel.invokeMethod("initReplicator");
    } on PlatformException {
      throw 'unable to init replicator';
    }
  }

  Future<Null> startReplicator() async {
    try {
      await _methodChannel.invokeMethod('startReplicator');
    } on PlatformException {
      throw 'unable to start replication';
    }
  }

  Future<Null> stopReplicator() async {
    try {
      await _methodChannel.invokeMethod('stopReplicator');
    } on PlatformException {
      throw 'unable to stop replication';
    }
  }

  Future<Map<dynamic, dynamic>> _getDocumentWithId(String _id) async {
    try {
      final Map<dynamic, dynamic> result =
      await _methodChannel.invokeMethod('getDocumentWithId', _id);
      return result;
    } on PlatformException {
      throw 'unable to get the document with id $_id';
    }
  }

  void listenReplicationEvents(Function(dynamic) function) {
    _replicationEventChannel.receiveBroadcastStream().listen(function);
  }
}
