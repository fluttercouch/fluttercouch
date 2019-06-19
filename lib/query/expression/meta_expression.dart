import 'expression.dart';

class MetaExpression extends Object with Expression {
  MetaExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }

  MetaExpression._clone(MetaExpression expression) {
    this.internalExpressionStack.addAll(expression.expressionStack);
  }

  @override
  MetaExpression clone() {
    return MetaExpression._clone(this);
  }
}
