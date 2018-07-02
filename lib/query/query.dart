import 'dart:async';

import 'package:flutter/services.dart';
import 'parameters.dart';

class Query {

  Map<String, String> options;
  Parameters param;

  static const MethodChannel _channel =
  const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  Query() {
    this.options = new Map<String, String>();
    this.param = new Parameters();
  }

  Future<String> execute() async {
    try {
      final String result =
      await _channel.invokeMethod('executeQuery', options);
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
}