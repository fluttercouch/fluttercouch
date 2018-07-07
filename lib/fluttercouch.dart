import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercouch/document.dart';

abstract class Fluttercouch {
  static const MethodChannel _channel =
      const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  Future<String> initDatabaseWithName(String _name) async {
    try {
      final String result =
          await _channel.invokeMethod('initDatabaseWithName', _name);
      return result;
    } on PlatformException catch (e) {
      throw 'unable to init database $_name: ${e.message}';
    }
  }

  Future<String> saveDocument(Map<String, dynamic> _map) async {
    try {
      final String result = await _channel.invokeMethod('saveDocument', _map);
      return result;
    } on PlatformException {
      throw 'unable to save the document';
    }
  }

  Future<String> saveDocumentWithId(String _id, Document _doc) async {
    try {
      final String result = await _channel.invokeMethod(
          'saveDocument', <String, dynamic>{'id': _id, 'map': _doc.toMap()});
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
          await _channel.invokeMethod('setReplicatorEndpoint', _endpoint);
      return result;
    } on PlatformException {
      throw 'unable to set target endpoint to $_endpoint';
    }
  }

  Future<String> setReplicatorType(String _type) async {
    try {
      final String result =
          await _channel.invokeMethod('setReplicatorType', _type);
      return result;
    } on PlatformException {
      throw 'unable to set replicator type to $_type';
    }
  }

  Future<String> setReplicatorBasicAuthentication(
      Map<String, String> _auth) async {
    try {
      final String result = await _channel.invokeMethod(
          'setReplicatorBasicAuthentication', _auth);
      return result;
    } on PlatformException {
      throw 'unable to set replicator authentication';
    }
  }

  Future<Null> startReplicator() async {
    try {
      await _channel.invokeMethod('startReplicator');
    } on PlatformException {
      throw 'unable to set replicator authentication';
    }
  }

  Future<Null> stopReplicator() async {
    try {
      await _channel.invokeMethod('stopReplicator');
    } on PlatformException {
      throw 'unable to set replicator authentication';
    }
  }

  Future<Map<dynamic, dynamic>> _getDocumentWithId(String _id) async {
    try {
      final Map<dynamic, dynamic> result =
      await _channel.invokeMethod('getDocumentWithId', _id);
      return result;
    } on PlatformException {
      throw 'unable to get the document with id $_id';
    }
  }
}
