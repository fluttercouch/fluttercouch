import 'expression.dart';

class PropertyExpression extends Object with Expression {
  PropertyExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }
}
