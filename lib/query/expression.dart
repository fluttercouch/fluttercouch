import 'package:fluttercouch/query/meta_expression.dart';
import 'package:fluttercouch/query/variable_expression.dart';

import 'property_expression.dart';

abstract class Expression {

  // static PropertyExpression all();

  static VariableExpression booleanValue(bool value) {
    var result = new VariableExpression();
    result.expr = "bool<" + value.toString() + ">|";
    return result;
  }

  // TODO: Implement date value in Expression
  // static Expression date(DateTime value);

  static VariableExpression doubleValue(double value) {
    var result = new VariableExpression();
    result.expr = "double<" + value.toString() + ">|";
    return result;
  }

  static VariableExpression intValue(int value) {
    var result = new VariableExpression();
    result.expr = "int<" + value.toString() + ">|";
    return result;
  }

  static MetaExpression negated(Expression expression) {
    var result = new MetaExpression();
    result.expr = "negated:" + expression.toString() + "|";
    return result;
  }

  static MetaExpression not(Expression expression) {
    var result = new MetaExpression();
    result.expr = "not:" + expression.toString() + "|";
    return result;
  }

  static PropertyExpression property(String property) {
    var result = new PropertyExpression();
    result.expr = "property<" + property + ">|";
    return result;
  }

  static VariableExpression string(String value) {
    var result = new VariableExpression();
    result.expr = "string<" + value + ">|";
    return result;

  }

  static VariableExpression value(Object value) {
    var result = new VariableExpression();
    result.expr = "object<" + value.toString() + ">|";
    return result;
  }

  Expression add(Expression expression);
  Expression and(Expression expression);
  Expression between(Expression expression1, Expression expression2);
  Expression divide(Expression expression);
  Expression equalTo(Expression expression);
  Expression greaterThan(Expression expression);
  Expression greaterThanOrEqual(Expression expression);
  // implement in(Expression... expressions) but lacking variable arguments number feature in Dart
  // implement is(Expression expression) but "is" is a reserved keyword
  Expression isNot(Expression expression);
  Expression isNullOrMissing();
  Expression lessThan(Expression expression);
  Expression lessThanOrEqualTo(Expression expression);
  Expression like(Expression expression);
  Expression modulo(Expression expression);
  Expression multiply(Expression expression);
  Expression notEqualTo(Expression expression);
  Expression notNullOrMissing();
  Expression or(Expression expression);
  Expression regex(Expression expression);
  Expression subtract(Expression expression);
  String toString();
}