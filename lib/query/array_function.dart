import 'package:fluttercouch/query/expression/expression.dart';

class ArrayFunction extends Object with Expression {
  Map<String, Expression> _internalExpression;

  ArrayFunction._internal(this._internalExpression);

  factory ArrayFunction.contains(Expression expression, Expression value) {
    return ArrayFunction
        ._internal({"contains": expression, "withValue": value});
  }

  factory ArrayFunction.length(Expression expression) {
    return ArrayFunction._internal({"length": expression});
  }

  toJson() {
    return _internalExpression;
  }
}
