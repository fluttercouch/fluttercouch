import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../listener_token.dart';

import 'query.dart';
import 'from.dart';
import 'functions.dart';
import 'group_by.dart';
import 'having.dart';
import 'join.dart';
import 'joins.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'parameters.dart';
import 'query_builder.dart';
import 'result.dart';
import 'result_set.dart';
import 'select.dart';
import 'select_result.dart';
import 'where.dart';

import 'expression/expression.dart';
import 'expression/meta.dart';
import 'expression/meta_expression.dart';
import 'expression/property_expression.dart';
import 'expression/variable_expression.dart';

class Result {
  Map<String, dynamic> _internalMap = {};
  List<dynamic> _internalList = [];

  bool contains(String key) {
    if (_internalMap != null) {
      return _internalMap.containsKey(key);
    } else if (_internalList != null) {
      return _internalList.contains(key);
    } else {
      return null;
    }
  }

  int count() {
    var result;
    if (null != _internalMap) {
      result = _internalMap.length;
    } else if (null != _internalList) {
      result = _internalList.length;
    }
    return result;
  }

  List<dynamic> getList({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is List<dynamic>) {
      return result;
    } else {
      return null;
    }
  }

  //TODO: implement getBlob()

  bool getBoolean({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is bool) {
      return result;
    } else {
      return null;
    }
  }

  //TODO: implement Date object and getDate

  double getDouble({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is double) {
      return result;
    } else {
      return null;
    }
  }

  int getInt({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is int) {
      return result;
    } else {
      return null;
    }
  }

  List<String> getKeys() {
    if (null != _internalMap && _internalMap.isNotEmpty) {
      return List.unmodifiable(_internalMap.keys);
    } else {
      return null;
    }
  }

  String getString({int index, String key}) {
    var result = getValue(index: index, key: key);
    if (result is String) {
      return result;
    } else {
      return null;
    }
  }

  Object getValue({int index, String key}) {
    var result;
    if (null != index && null == key) {
      if (_internalList.length > index) {
        result = _internalList[index];
      }
    }
    if (null != key && null == index) {
      if (_internalMap.containsKey(key)) {
        result = _internalMap[key];
      }
    }
    return result;
  }

  //TODO: implement iterator()

  List<dynamic> toList() {
    return _internalList;
  }

  Map<String, dynamic> toMap() {
    return _internalMap;
  }

  void setMap(Map<String, dynamic> map) {
    _internalMap.clear();
    _internalMap.addAll(map);
  }

  void setList(List<dynamic> list) {
    _internalList.clear();
    _internalList.addAll(list);
  }
}
