import 'package:fluttercouch/query/expression/meta_expression.dart';
import 'package:fluttercouch/query/expression/property_expression.dart';
import 'package:fluttercouch/query/expression/variable_expression.dart';

abstract class Expression {
  final List<Map<String, dynamic>> internalExpressionStack = new List();

  factory Expression.booleanValue(bool value) {
    return VariableExpression({"booleanValue": value});
  }

  factory Expression.doubleValue(double value) {
    return VariableExpression({"doubleValue": value});
  }

  // TODO: Implement date value in Expression
  // static Expression date(DateTime value);

  factory Expression.intValue(int value) {
    return VariableExpression({"intValue": value});
  }

  factory Expression.value(Object value) {
    return VariableExpression({"value": value});
  }

  factory Expression.string(String value) {
    return VariableExpression({"string": value});
  }

  factory Expression.property(String value) {
    return PropertyExpression({"property": value});
  }

  factory Expression.negated(Expression expression) {
    return MetaExpression({"negated": expression.internalExpressionStack});
  }

  factory Expression.not(Expression expression) {
    return MetaExpression({"not": expression.internalExpressionStack});
  }

  Expression add(Expression expression) {
    return _addExpression("add", expression);
  }

  Expression and(Expression expression) {
    return _addExpression("and", expression);
  }

  Expression between(Expression expression1, Expression expression2) {
    return _addExpression("between", expression1,
        secondSelector: "and", secondExpression: expression2);
  }

  Expression divide(Expression expression) {
    return _addExpression("divide", expression);
  }

  Expression equalTo(Expression expression) {
    return _addExpression("equalTo", expression);
  }

  Expression greaterThan(Expression expression) {
    return _addExpression("greaterThan", expression);
  }

  Expression greaterThanOrEqualTo(Expression expression) {
    return _addExpression("greaterThanOrEqualTo", expression);
  }

  // implement in(Expression... expressions) but lacking variable arguments number feature in Dart
  Expression In(List<Expression> listExpression) {
    return _addList("in", listExpression);
  }

  // implement is(Expression expression) but "is" is a reserved keyword

  Expression isNot(Expression expression) {
    return _addExpression("isNot", expression);
  }

  Expression isNullOrMissing(Expression expression) {
    return _addExpression("isNullOrMissing", expression);
  }

  Expression lessThan(Expression expression) {
    return _addExpression("lessThan", expression);
  }

  Expression lessThanOrEqualTo(Expression expression) {
    return _addExpression("lessThanOrEqualTo", expression);
  }

  Expression like(Expression expression) {
    return _addExpression("like", expression);
  }

  Expression modulo(Expression expression) {
    return _addExpression("modulo", expression);
  }

  Expression multiply(Expression expression) {
    return _addExpression("multiply", expression);
  }

  Expression notEqualTo(Expression expression) {
    return _addExpression("notEqualTo", expression);
  }

  Expression notNullOrMissing(Expression expression) {
    return _addExpression("notNullOrMissing", expression);
  }

  Expression or(Expression expression) {
    return _addExpression("or", expression);
  }

  Expression regex(Expression expression) {
    return _addExpression("regex", expression);
  }

  Expression subtract(Expression expression) {
    return _addExpression("subtract", expression);
  }

  Expression from(String alias) {
    internalExpressionStack.add({"from": alias});
    return this;
  }

  toJson() {
    return internalExpressionStack;
  }

  Expression _addExpression(String selector, Expression expression,
      {String secondSelector, Expression secondExpression}) {
    if (secondSelector != null && secondExpression != null) {
      internalExpressionStack.add({
        selector: expression.internalExpressionStack,
        secondSelector: secondExpression.internalExpressionStack
      });
    } else {
      internalExpressionStack
          .add({selector: expression.internalExpressionStack});
    }
    return this;
  }

  Expression _addList(String selector, List<Expression> listExpression) {
    internalExpressionStack.add({selector: listExpression});
    return this;
  }
}
