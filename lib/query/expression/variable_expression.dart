import 'expression.dart';

class VariableExpression extends Object with Expression {
  VariableExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }

  VariableExpression._clone(VariableExpression expression) {
    this.internalExpressionStack.addAll(expression.expressionStack);
  }

  @override
  VariableExpression clone() {
    return VariableExpression._clone(this);
  }
}
