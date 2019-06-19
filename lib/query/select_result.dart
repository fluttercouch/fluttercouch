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

class SelectResult {
  static SelectResultFrom all() => SelectResultFrom(Expression.all(), null);

  static SelectResultAs property(String _property) =>
      expression(Expression.property(_property));

  static SelectResultAs expression(Expression _expression) =>
      SelectResultAs(_expression, null);
}

class SelectResultProtocol {
  SelectResultProtocol(Expression expression, {String alias}) {
    this.expression = expression;
    this.alias = alias;
  }

  Expression expression;
  String alias;

  List<Map<String, dynamic>> toJson() {
    if (alias != null) {
      return expression.expressionStack +
          [
            {"as": alias}
          ];
    } else {
      return expression.expressionStack;
    }
  }
}

class SelectResultAs extends SelectResultProtocol {
  SelectResultAs(Expression expression, String alias)
      : super(expression, alias: alias);

  SelectResultProtocol as(String _alias) {
    return SelectResultProtocol(this.expression, alias: _alias);
  }
}

class SelectResultFrom extends SelectResultProtocol {
  SelectResultFrom(Expression expression, String alias)
      : super(expression, alias: alias);

  SelectResultProtocol from(String _alias) {
    return SelectResultProtocol(Expression.all().from(_alias));
  }
}
