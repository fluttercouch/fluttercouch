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
  Map<ListenerToken,StreamSubscription> tokens = {};
  int refCount = 0;

  //static const JSONMessageCodec _json = const JSONMessageCodec();

  static const JSONMethodCodec _jsonMethod = const JSONMethodCodec();

  static const MethodChannel _channel = const MethodChannel('it.oltrenuovefrontiere.fluttercouchJson', _jsonMethod);

  EventChannel _queryEventChannel;
  Stream _stream;

  Query() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
    _queryEventChannel = EventChannel("it.oltrenuovefrontiere.fluttercouch/queryEventChannel/"+queryId, _jsonMethod);
    _stream = _queryEventChannel.receiveBroadcastStream({"query":queryId});
  }

  Future<ResultSet> execute() async {
    try {
      this.options["queryId"] = queryId;
      final List<dynamic> resultSet = await _channel.invokeMethod('execute', this);

      List<Result> results = List<Result>();
      for(dynamic result in resultSet) {
        Result newResult = Result();
        newResult.setMap(result["map"]);
        newResult.setList(result["list"]);
        results.add(newResult);
      }

      return ResultSet(results);
    } on PlatformException catch (e) {
      // Remove all listeners on error
      tokens.keys.forEach((token) {
        removeChangeListener(token);
      });

      throw 'unable to execute the query: ${this.toJson()}\n ${e.message}';
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

  Future<ListenerToken> addChangeListener(ListenerCallback callback) {
    this.options["queryId"] = queryId;
    refCount++;

    return () async {
      if (!_stored) {
        _stored = await _channel.invokeMethod('store', this);
      }

      if (_stored) {
        var token = ListenerToken();
        tokens[token] = _stream.listen((data) {
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
          await removeChangeListener(token);
          return null;
        }

        return token;
      } else {
        return null;
      }
    }();
  }

  Future<void> removeChangeListener(ListenerToken token) {
    refCount--;
    final subscription = tokens.remove(token);

    return () async {
      if (subscription != null) {
        // This will automatically remove all references from the platform
        await subscription.cancel();
      }

      if (refCount == 0) {
        // We had to store this before listening to so if stored on the platform
        _stored = false;
        await _channel.invokeMethod('remove', this);
      }
    }();
  }

  Map<String, dynamic> toJson() => options;
}

class QueryChange {
  final Query query;
  final ResultSet results;
  final String error;

  QueryChange({this.query,this.results,this.error}) : assert(query != null);
}
