import 'package:fluttercouch/query/expression/expression.dart';

class Ordering {
  Expression _internalExpression;

  Ordering._internal(Expression _expression) {
    this._internalExpression = _expression;
  }

  factory Ordering.property(String _property) {
    return Ordering._internal(Expression.property(_property));
  }

  factory Ordering.expression(Expression _expression) {
    return Ordering._internal(_expression);
  }

  toJson() {
    return _internalExpression.internalExpressionStack;
  }

  Ordering ascending() {
    this._internalExpression.internalExpressionStack.add(
        {"orderingSortOrder": "ascending"});
    return this;
  }

  Ordering descending() {
    this._internalExpression.internalExpressionStack.add(
        {"orderingSortOrder": "descending"});
    return this;
  }
}
