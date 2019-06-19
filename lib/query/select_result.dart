import 'expression/expression.dart';

class SelectResult {
  static SelectResultFrom all() => SelectResultFrom(Expression.all(), null);

  static SelectResultAs property(String _property) =>
      expression(Expression.property(_property));

  static SelectResultAs expression(Expression _expression) =>
      SelectResultAs(_expression, null);
}

class SelectResultProtocol {
  SelectResultProtocol(Expression expression, {String alias}) {
    this.expression = expression;
    this.alias = alias;
  }

  Expression expression;
  String alias;

  List<Map<String, dynamic>> toJson() {
    if (alias != null) {
      return expression.expressionStack +
          [
            {"as": alias}
          ];
    } else {
      return expression.expressionStack;
    }
  }
}

class SelectResultAs extends SelectResultProtocol {
  SelectResultAs(Expression expression, String alias)
      : super(expression, alias: alias);

  SelectResultProtocol as(String _alias) {
    return SelectResultProtocol(this.expression, alias: _alias);
  }
}

class SelectResultFrom extends SelectResultProtocol {
  SelectResultFrom(Expression expression, String alias)
      : super(expression, alias: alias);

  SelectResultProtocol from(String _alias) {
    return SelectResultProtocol(Expression.all().from(_alias));
  }
}
