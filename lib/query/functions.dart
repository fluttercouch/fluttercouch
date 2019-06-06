import 'package:fluttercouch/query/expression/expression.dart';

class Functions extends Object with Expression {
  final List<Map<String, dynamic>> internalExpressionStack = new List();

  Functions(Map<String, dynamic> _passedInternalExpression) {
    this.internalExpressionStack.add(_passedInternalExpression);
  }

  factory Functions.abs(Expression expression) {
    return Functions({"abs": expression});
  }

  factory Functions.acos(Expression expression) {
    return Functions({"acos": expression});
  }

  factory Functions.asin(Expression expression) {
    return Functions({"asin": expression});
  }

  factory Functions.atan(Expression expression) {
    return Functions({"atan": expression});
  }

  factory Functions.atan2(Expression x, Expression y) {
    return Functions({"atan2": x, "y": y});
  }

  factory Functions.avg(Expression expression) {
    return Functions({"avg": expression});
  }

  factory Functions.ceil(Expression expression) {
    return Functions({"ceil": expression});
  }

  factory Functions.contains(Expression expression, Expression substring) {
    return Functions({"atan2": expression, "y": substring});
  }

  factory Functions.cos(Expression expression) {
    return Functions({"cos": expression});
  }

  factory Functions.count(Expression expression) {
    return Functions({"count": expression});
  }

  factory Functions.degrees(Expression expression) {
    return Functions({"degrees": expression});
  }

  factory Functions.e() {
    return Functions({"e": null});
  }

  factory Functions.exp(Expression expression) {
    return Functions({"exp": expression});
  }

  factory Functions.floor(Expression expression) {
    return Functions({"floor": expression});
  }

  factory Functions.length(Expression expression) {
    return Functions({"length": expression});
  }

  factory Functions.ln(Expression expression) {
    return Functions({"ln": expression});
  }

  factory Functions.log(Expression expression) {
    return Functions({"log": expression});
  }

  factory Functions.lower(Expression expression) {
    return Functions({"lower": expression});
  }

  factory Functions.ltrim(Expression expression) {
    return Functions({"ltrim": expression});
  }

  factory Functions.max(Expression expression) {
    return Functions({"max": expression});
  }

  factory Functions.min(Expression expression) {
    return Functions({"min": expression});
  }

  factory Functions.pi() {
    return Functions({"pi": null});
  }

  factory Functions.power(Expression base, Expression exponent) {
    return Functions({"power": base, "exponent": exponent});
  }

  factory Functions.radians(Expression expression) {
    return Functions({"radians": expression});
  }

  factory Functions.round(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({"round": expression, "digits": digits});
    } else {
      return Functions({"round": expression});
    }
  }

  factory Functions.rtrim(Expression expression) {
    return Functions({"rtrim": expression});
  }

  factory Functions.sign(Expression expression) {
    return Functions({"sign": expression});
  }

  factory Functions.sin(Expression expression) {
    return Functions({"sin": expression});
  }

  factory Functions.sqrt(Expression expression) {
    return Functions({"sqrt": expression});
  }

  factory Functions.sum(Expression expression) {
    return Functions({"sum": expression});
  }

  factory Functions.tan(Expression expression) {
    return Functions({"tan": expression});
  }

  factory Functions.trim(Expression expression) {
    return Functions({"trim": expression});
  }

  factory Functions.trunc(Expression expression, {Expression digits}) {
    if (digits != null) {
      return Functions({"trunc": expression, "digits": digits});
    } else {
      return Functions({"trunc": expression});
    }
  }

  factory Functions.upper(Expression expression) {
    return Functions({"upper": expression});
  }

  toJson() {
    return internalExpressionStack;
  }
}
