import 'dart:async';

import 'package:flutter/services.dart';

import 'parameters.dart';

class Query {
  Map<String, dynamic> options;
  Parameters param;

  static const MessageCodec<dynamic> _json = const JSONMessageCodec();

  static const MethodCodec _jsonMethod = const JSONMethodCodec();

  static const MethodChannel _channel =
  const MethodChannel(
      'it.oltrenuovefrontiere.fluttercouchJson', _jsonMethod);

  Query() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  Future<Map<String, dynamic>> execute() async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod(
          'execute', this);
      return result;
    } on PlatformException catch (e) {
      throw 'unable to execute the query: ${e.message}';
    }
  }

  String explain() {
    return "";
  }

  Parameters getParameters() {
    return param;
  }

  setParameters(Parameters parameters) {
    param = parameters;
  }

  Map<String, dynamic> toJson() => options;
}
