import 'dart:core';

class CouchbaseLiteException implements Exception {
  final int code;
  final String domain;
  final Map<String, dynamic> info;

  const CouchbaseLiteException([this.code = 0, this.domain = "", this.info]);

  int getCode() => code;
  String getDomain() => domain;
  Map<String, dynamic> getInfo() => info;
}