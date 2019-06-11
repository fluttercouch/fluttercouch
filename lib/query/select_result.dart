import 'package:fluttercouch/query/expression/expression.dart';

class SelectResult {
  static SelectResultFrom all() => SelectResultFrom(Expression.all(), null);

  static SelectResultAs property(String _property) =>
      expression(Expression.property(_property));

  static SelectResultAs expression(Expression _expression) =>
      SelectResultAs(_expression, null);
}

class SelectResultProtocol {
  Expression expression;
  String alias;

  SelectResultProtocol(Expression expression, {String alias}) {
    this.expression = expression;
    this.alias = alias;
  }

  toJson() {
    if (alias != null) {
      return expression.internalExpressionStack +
          [
            {"as": alias}
          ];
    } else {
      return expression.internalExpressionStack;
    }
  }
}

class SelectResultAs extends SelectResultProtocol {
  SelectResultAs(Expression expression, String alias)
      : super(expression, alias: alias);

  SelectResultProtocol As(String _alias) {
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
