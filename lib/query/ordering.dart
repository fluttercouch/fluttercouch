import 'dart:convert';

import 'package:fluttercouch/query/expression/expression.dart';

class Ordering {
  Expression _internalExpression;

  Ordering();

  Ordering._internal(Expression _expression) {
    this._internalExpression = _expression;
  }

  factory Ordering.property(String _property) {
    return OrderingSortOrder(
        (Expression.property(_property).internalExpressionStack));
  }

  factory Ordering.expression(Expression _expression) {
    return OrderingSortOrder(_expression.internalExpressionStack);
  }

  toJson() {
    return json.encode(_internalExpression.internalExpressionStack);
  }
}

class OrderingSortOrder extends Ordering {
  List<Map<String, dynamic>> _internalStack = List();

  OrderingSortOrder(List<Map<String, dynamic>> _internalStack) {
    this._internalStack.add(_internalStack);
  }

  factory OrderingSortOrder.ascending() {
    return OrderingSortOrder({"orderingSortOrder": "ascending"});
  }

  factory OrderingSortOrder.descending() {
    return OrderingSortOrder({"orderingSortOrder": "descending"});
  }

  toJson() {
    return json.encode(_internalExpression.internalExpressionStack);
  }
}
