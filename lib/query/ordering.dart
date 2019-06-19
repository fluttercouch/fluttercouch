import 'expression/expression.dart';

class Ordering {
  Ordering._internal(Expression _expression) {
    this._internalExpression = _expression;
  }

  factory Ordering.property(String _property) {
    return Ordering._internal(Expression.property(_property));
  }

  factory Ordering.expression(Expression _expression) {
    return Ordering._internal(_expression);
  }

  Expression _internalExpression;

  Ordering ascending() {
    Expression clone = _internalExpression.clone();
    clone.internalExpressionStack.add({"orderingSortOrder": "ascending"});
    return Ordering._internal(clone);
  }

  Ordering descending() {
    Expression clone = _internalExpression.clone();
    clone.internalExpressionStack.add({"orderingSortOrder": "descending"});
    return Ordering._internal(clone);
  }

  List<Map<String, dynamic>> toJson() {
    return _internalExpression.expressionStack;
  }
}
