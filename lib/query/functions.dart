import 'expression/expression.dart';

class Functions extends Object with Expression {
  Functions(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }

  Functions._clone(Functions expression) {
    this.internalExpressionStack.addAll(expression.expressionStack);
  }

  factory Functions.abs(Expression expression) {
    return Functions({"abs": expression.expressionStack});
  }

  factory Functions.acos(Expression expression) {
    return Functions({"acos": expression.expressionStack});
  }

  factory Functions.asin(Expression expression) {
    return Functions({"asin": expression.expressionStack});
  }

  factory Functions.atan(Expression expression) {
    return Functions({"atan": expression.expressionStack});
  }

  factory Functions.atan2(Expression x, Expression y) {
    return Functions({"atan2": x.expressionStack, "y": y.expressionStack});
  }

  factory Functions.avg(Expression expression) {
    return Functions({"avg": expression.expressionStack});
  }

  factory Functions.ceil(Expression expression) {
    return Functions({"ceil": expression.expressionStack});
  }

  factory Functions.contains(Expression expression, Expression substring) {
    return Functions({
      "contains": expression.expressionStack,
      "y": substring.expressionStack
    });
  }

  factory Functions.cos(Expression expression) {
    return Functions({"cos": expression.expressionStack});
  }

  factory Functions.count(Expression expression) {
    return Functions({"count": expression.expressionStack});
  }

  factory Functions.degrees(Expression expression) {
    return Functions({"degrees": expression.expressionStack});
  }

  factory Functions.e() {
    return Functions({"e": null});
  }

  factory Functions.exp(Expression expression) {
    return Functions({"exp": expression.expressionStack});
  }

  factory Functions.floor(Expression expression) {
    return Functions({"floor": expression.expressionStack});
  }

  factory Functions.length(Expression expression) {
    return Functions({"length": expression.expressionStack});
  }

  factory Functions.ln(Expression expression) {
    return Functions({"ln": expression.expressionStack});
  }

  factory Functions.log(Expression expression) {
    return Functions({"log": expression.expressionStack});
  }

  factory Functions.lower(Expression expression) {
    return Functions({"lower": expression.expressionStack});
  }

  factory Functions.ltrim(Expression expression) {
    return Functions({"ltrim": expression.expressionStack});
  }

  factory Functions.max(Expression expression) {
    return Functions({"max": expression.expressionStack});
  }

  factory Functions.min(Expression expression) {
    return Functions({"min": expression.expressionStack});
  }

  factory Functions.pi() {
    return Functions({"pi": null});
  }

  factory Functions.power(Expression base, Expression exponent) {
    return Functions(
        {"power": base.expressionStack, "exponent": exponent.expressionStack});
  }

  factory Functions.radians(Expression expression) {
    return Functions({"radians": expression.expressionStack});
  }

  factory Functions.round(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({
        "round": expression.expressionStack,
        "digits": digits.expressionStack
      });
    } else {
      return Functions({"round": expression.expressionStack});
    }
  }

  factory Functions.rtrim(Expression expression) {
    return Functions({"rtrim": expression.expressionStack});
  }

  factory Functions.sign(Expression expression) {
    return Functions({"sign": expression.expressionStack});
  }

  factory Functions.sin(Expression expression) {
    return Functions({"sin": expression.expressionStack});
  }

  factory Functions.sqrt(Expression expression) {
    return Functions({"sqrt": expression.expressionStack});
  }

  factory Functions.sum(Expression expression) {
    return Functions({"sum": expression.expressionStack});
  }

  factory Functions.tan(Expression expression) {
    return Functions({"tan": expression.expressionStack});
  }

  factory Functions.trim(Expression expression) {
    return Functions({"trim": expression.expressionStack});
  }

  factory Functions.trunc(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({
        "trunc": expression.expressionStack,
        "digits": digits.expressionStack
      });
    } else {
      return Functions({"trunc": expression.expressionStack});
    }
  }

  factory Functions.upper(Expression expression) {
    return Functions({"upper": expression.expressionStack});
  }

  @override
  Functions clone() {
    return Functions._clone(this);
  }
}
