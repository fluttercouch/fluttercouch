import 'meta_expression.dart';
import 'property_expression.dart';
import 'variable_expression.dart';

abstract class Expression {
  factory Expression.all() {
    return PropertyExpression({"property": null});
  }

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

  final List<Map<String, dynamic>> internalExpressionStack = new List();

  List<Map<String, dynamic>> get expressionStack =>
      List.from(internalExpressionStack);

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
  Expression iN(List<Expression> listExpression) {
    return _addList("in", listExpression);
  }

  Expression iS(Expression expression) {
    return _addExpression("is", expression);
  }

  Expression isNot(Expression expression) {
    return _addExpression("isNot", expression);
  }

  Expression isNullOrMissing() {
    Expression clone = this.clone();
    clone.internalExpressionStack.add({"isNullOrMissing": null});
    return clone;
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

  Expression notNullOrMissing() {
    Expression clone = this.clone();
    clone.internalExpressionStack.add({"notNullOrMissing": null});
    return clone;
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
    Expression fromExpression = this.clone();
    fromExpression.internalExpressionStack.add({"from": alias});
    return fromExpression;
  }

  Expression _addExpression(String selector, Expression expression,
      {String secondSelector, Expression secondExpression}) {
    Expression clone = this.clone();
    if (secondSelector != null && secondExpression != null) {
      clone.internalExpressionStack.add({
        selector: expression.expressionStack,
        secondSelector: secondExpression.expressionStack
      });
    } else {
      clone.internalExpressionStack.add({selector: expression.expressionStack});
    }
    return clone;
  }

  Expression _addList(String selector, List<Expression> listExpression) {
    Expression clone = this.clone();
    List json = [];
    listExpression.forEach((expression) {
      json.add(expression.expressionStack);
    });
    clone.internalExpressionStack.add({selector: json});
    return clone;
  }

  Expression clone();

  List<Map<String, dynamic>> toJson() => expressionStack;
}
