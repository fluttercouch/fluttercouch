import 'expression.dart';

class MetaExpression extends Expression {
  String expr = "";

  Expression from(String alias) {
    this.expr = this.expr + "from<" + alias + ">|";
    return this;
  }

  @override
  String toString() {
    return expr;
  }

  @override
  Expression subtract(Expression expression) {
    append(selector: "subtract", expression: expression);
    return this;
  }

  @override
  Expression regex(Expression expression) {
    append(selector: "regex", expression: expression);
    return this;
  }

  @override
  Expression or(Expression expression) {
    append(selector: "or", expression: expression);
    return this;
  }

  @override
  Expression notNullOrMissing() {
    this.expr = this.expr + "notNullOrMissing|";
    return this;
  }

  @override
  Expression notEqualTo(Expression expression) {
    append(selector: "notEqualTo", expression: expression);
    return this;
  }

  @override
  Expression multiply(Expression expression) {
    append(selector: "multiply", expression: expression);
    return this;
  }

  @override
  Expression modulo(Expression expression) {
    append(selector: "modulo", expression: expression);
    return this;
  }

  @override
  Expression like(Expression expression) {
    append(selector: "like", expression: expression);
    return this;
  }

  @override
  Expression lessThanOrEqualTo(Expression expression) {
    append(selector: "lessThanOrEqualTo", expression: expression);
    return this;
  }

  @override
  Expression lessThan(Expression expression) {
    append(selector: "lessThan", expression: expression);
    return this;
  }

  @override
  Expression isNullOrMissing() {
    this.expr = this.expr + "isNullOrMissing|";
    return this;
  }

  @override
  Expression isNot(Expression expression) {
    append(selector: "isNot", expression: expression);
    return this;
  }

  @override
  Expression greaterThanOrEqual(Expression expression) {
    append(selector: "greaterThanOrEqual", expression: expression);
    return this;
  }

  @override
  Expression greaterThan(Expression expression) {
    append(selector: "greaterThan", expression: expression);
    return this;
  }

  @override
  Expression equalTo(Expression expression) {
    append(selector: "equalTo", expression: expression);
    return this;
  }

  @override
  Expression divide(Expression expression) {
    append(selector: "divide", expression: expression);
    return this;
  }

  @override
  Expression between(Expression expression1, Expression expression2) {
    this.expr = this.expr + "between(" + expression1.toString() + expression2.toString() + ")|";
    return this;
  }

  @override
  Expression and(Expression expression) {
    append(selector: "and", expression: expression);
    return this;
  }

  @override
  Expression add(Expression expression) {
    append(selector: "add", expression: expression);
    return this;
  }

  void append({String selector = "", Expression expression}) {
    if (selector != "") {
      this.expr = this.expr + selector + "(" + expression.toString() + ")|";
    } else {
      this.expr = this.expr + expression.toString() + "|";
    }
  }
}