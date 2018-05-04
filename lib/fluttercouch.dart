import 'dart:async';

import 'package:flutter/services.dart';

class Fluttercouch {
  static const MethodChannel _channel = const MethodChannel('it.oltrenuovefrontiere.fluttercouch');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
