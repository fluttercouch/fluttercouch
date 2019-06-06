import 'expression.dart';

class VariableExpression extends Object with Expression {
  VariableExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }
}
