import 'package:fluttercouch/query/expression/expression.dart';

class SelectResult {
  Expression _internalExpression;

  SelectResult._internal(Expression _expression) {
    this._internalExpression = _expression;
  }

  factory SelectResult.all() {
    return SelectResult._internal(Expression.string("all"));
  }

  factory SelectResult.property(String _property) {
    return SelectResult._internal((Expression.property(_property)));
  }

  factory SelectResult.expression(Expression _expression) {
    return SelectResult._internal(_expression);
  }

  SelectResult from(String _alias) {
    _internalExpression.internalExpressionStack.add({"from": _alias});
    return this;
  }

  SelectResult As(String _alias) {
    _internalExpression.internalExpressionStack.add({"as": _alias});
    return this;
  }

  toJson() {
    return _internalExpression.internalExpressionStack;
  }
}
