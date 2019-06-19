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

class Join {
  Join._internal(String selector, String _dataSource, {String as}) {
    if (as != null) {
      this._internalStack.add({selector: _dataSource, "as": as});
    } else {
      this._internalStack.add({selector: _dataSource});
    }
  }

  factory Join.join(String _dataSource, {String as}) {
    return Join._internal("join", _dataSource, as: as);
  }

  factory Join.crossJoin(String _dataSource, {String as}) {
    return Join._internal("crossJoin", _dataSource, as: as);
  }

  factory Join.innerJoin(String _dataSource, {String as}) {
    return Join._internal("innerJoin", _dataSource, as: as);
  }

  factory Join.leftJoin(String _dataSource, {String as}) {
    return Join._internal("leftJoin", _dataSource, as: as);
  }

  factory Join.leftOuterJoin(String _dataSource, {String as}) {
    return Join._internal("leftOuterJoin", _dataSource, as: as);
  }

  List<Map<String, dynamic>> _internalStack = List();

  Join on(Expression _expression) {
    this._internalStack.add({"on": _expression});
    return this;
  }

  List<Map<String, dynamic>> toJson() => _internalStack;
}
