import 'dart:async';

import 'package:flutter/services.dart';

class Fluttercouch {
  static const MethodChannel _channel = const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  static Future<String> get platformVersion async {
    try {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
    } on PlatformException {
      throw 'Unable to getPlatformVersion';
    }
  }

  static Future<String> initDatabaseWithName(String _name) async {
    try {
      final String result = await _channel.invokeMethod('initDatabaseWithName', _name);
      return result;
    } on PlatformException catch (e) {
      throw 'unable to init database $_name: ${e.message}';
    }
  }

  static Future<String> saveDocument(Map<String, dynamic> _map) async {
    try {
    final String result = await _channel.invokeMethod('saveDocument', _map);
    return result;
    } on PlatformException {
      throw 'unable to save the document';
    }
  }

  static Future<String> saveDocumentWithId(String _id, Map<String, dynamic> _map) async {
    try {
    final String result = await _channel.invokeMethod('saveDocument', <String, dynamic> {
      'id': _id,
      'map': _map
    });
    return result;
    } on PlatformException {
      throw 'unable to save the document with setted id $_id';
    }
  }
  
    static Future<Map<String, dynamic>> getDocumentWithId(String _id) async {
    try {
    final Map<String, dynamic> result = await _channel.invokeMethod('getDocumentWithId', _id);
    return result;
    } on PlatformException {
      throw 'unable to get the document with id $_id';
    }
  }
}
