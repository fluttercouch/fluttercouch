import 'expression.dart';

class PropertyExpression extends Object with Expression {
  PropertyExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }

  PropertyExpression._clone(PropertyExpression expression) {
    this.internalExpressionStack.addAll(expression.expressionStack);
  }

  @override
  PropertyExpression clone() {
    return PropertyExpression._clone(this);
  }
}
