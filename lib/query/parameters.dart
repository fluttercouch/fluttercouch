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

class Parameters {
  /*Map<String, dynamic> map;

  dynamic getValue(String name) {
    if (map.containsKey(name)) {
      return map[name];
    } else {
      return null;
    }
  }

  Parameters setBoolean(String name, bool value) {
    map[name] = value;
    return this;
  }

  Parameters setDate(String name, DateTime value) {
    map[name] = value;
    return this;
  }

  Parameters setDouble(String name, double value) {
    map[name] = value;
    return this;
  }

  Parameters setInt(String name, int value) {
    map[name] = value;
    return this;
  }

  Parameters setString(String name, String value) {
    map[name] = value;
    return this;
  }

  Parameters setValue(String name, dynamic value) {
    map[name] = value;
    return this;
  }*/
}
