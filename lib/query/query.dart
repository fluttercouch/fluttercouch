import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import 'parameters.dart';
import 'result_set.dart';
import 'result.dart';
import 'listener_token.dart';

typedef ListenerCallback = Function(QueryChange);

class Query {
  final queryId = Uuid().v1();
  bool _stored = false;
  Map<String, dynamic> options;
  Parameters param;
  Map<ListenerToken, StreamSubscription> tokens = {};

  static const JSONMethodCodec _jsonMethod = const JSONMethodCodec();

  static const MethodChannel _channel = const MethodChannel(
      'it.oltrenuovefrontiere.fluttercouchJson', _jsonMethod);

  static const EventChannel _queryEventChannel = const EventChannel(
      "it.oltrenuovefrontiere.fluttercouch/queryEventChannel", _jsonMethod);

  static final Stream _stream = _queryEventChannel.receiveBroadcastStream();

  Query() {
    this.param = new Parameters();
  }

  Future<ResultSet> execute() async {
    this.options["queryId"] = queryId;

    if (!_stored && tokens.length > 0) {
      _stored = await _channel.invokeMethod('store', this);
    }

    try {
      final List<dynamic> resultSet =
          await _channel.invokeMethod('execute', this);

      List<Result> results = List<Result>();
      for (dynamic result in resultSet) {
        Result newResult = Result();
        newResult.setMap(result["map"]);
        newResult.setList(result["list"]);
        results.add(newResult);
      }

      return ResultSet(results);
    } on PlatformException {
      // Remove all listeners on error
      tokens.keys.forEach((token) {
        removeChangeListener(token);
      });

      rethrow;
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

  Future<ListenerToken> addChangeListener(ListenerCallback callback) async {
    var token = ListenerToken();
    tokens[token] =
        _stream.where((data) => data["query"] == queryId).listen((data) {
      Map<String, dynamic> qcJson = data;
      final List<dynamic> resultList = qcJson["results"];

      ResultSet result;

      if (resultList != null) {
        List<Result> results = List<Result>();
        for (dynamic result in resultList) {
          Result newResult = Result();
          newResult.setMap(result["map"]);
          newResult.setList(result["list"]);
          results.add(newResult);
        }
        result = ResultSet(results);
      }

      String error = qcJson["error"];

      callback(QueryChange(query: this, results: result, error: error));
    });

    if (tokens[token] == null) {
      // Listener didn't subscribe to stream
      tokens.remove(token);
      return null;
    }

    return token;
  }

  Future<void> removeChangeListener(ListenerToken token) async {
    final subscription = tokens.remove(token);

    if (subscription != null) {
      await subscription.cancel();
    }

    if (_stored && tokens.length == 0) {
      // We had to store this before listening to so if stored on the platform
      _stored = !await _channel.invokeMethod('remove', this);
    }
  }

  Map<String, dynamic> toJson() => options;
}

class QueryChange {
  final Query query;
  final ResultSet results;
  final String error;

  QueryChange({this.query, this.results, this.error}) : assert(query != null);
}
