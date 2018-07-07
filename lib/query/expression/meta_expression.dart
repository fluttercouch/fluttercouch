import 'expression.dart';

class MetaExpression extends Object with Expression {
  MetaExpression(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }
}
