import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/query/expression.dart';

void main() {
  group("Value building static methods", () {
    test("booleanValue()", () {
      expect(Expression.booleanValue(true).toString(), equals("bool<true>|"));
    });
    test("doubleValue()", () {
      expect(Expression.doubleValue(1452.45212).toString(), equals("double<1452.45212>|"));
    });
    test("intValue()", () {
      expect(Expression.intValue(1452).toString(), equals("int<1452>|"));
    });
    test("negated()", () {
      expect(Expression.negated(Expression.booleanValue(true)).toString(), equals("negated:bool<true>||"));
    });
    test("not()", () {
      expect(Expression.not(Expression.booleanValue(false)).toString(), equals("not:bool<false>||"));
    });
    test("property()", () {
      expect(Expression.property("aPropertyName").toString(), equals("property<aPropertyName>|"));
    });
    test("string()", () {
      expect(Expression.string("aString").toString(), equals("string<aString>|"));
    });
    test("value()", () {
      expect(Expression.value(54.12).toString(), equals("object<54.12>|"));
    });
  });

  group("Expression building instance methods", () {
    test("add()", () {
      expect(Expression.booleanValue(true).add(Expression.string("aStringValue")).toString(), equals("bool<true>|add(string<aStringValue>|)|"));
    });
    test("and()", () {
      expect(Expression.booleanValue(true).and(Expression.string("aStringValue")).toString(), equals("bool<true>|and(string<aStringValue>|)|"));
    });
    test("between()", () {
      expect(Expression.booleanValue(true).between(Expression.string("firstStringValue"), Expression.string("secondStringValue")).toString(), equals("bool<true>|between(string<firstStringValue>|string<secondStringValue>|)|"));
    });
    test("divide()", () {
      expect(Expression.doubleValue(16.0).divide(Expression.doubleValue(2.0)).toString(), equals("double<16.0>|divide(double<2.0>|)|"));
    });
    test("equalTo()", () {
      expect(Expression.doubleValue(16.0).equalTo(Expression.doubleValue(16.0)).toString(), equals("double<16.0>|equalTo(double<16.0>|)|"));
    });
    test("greatherThan()", () {
      expect(Expression.doubleValue(16.0).greaterThan(Expression.doubleValue(2.0)).toString(), equals("double<16.0>|greaterThan(double<2.0>|)|"));
    });
    test("greatherThanOrEqualTo()", () {
      expect(Expression.doubleValue(16.0).greaterThanOrEqual(Expression.doubleValue(2.0)).toString(), equals("double<16.0>|greaterThanOrEqual(double<2.0>|)|"));
    });
    test("isNot()", () {
      expect(Expression.doubleValue(16.0).isNot(Expression.doubleValue(2.0)).toString(), equals("double<16.0>|isNot(double<2.0>|)|"));
    });
    test("isNullOrMissing()", () {
      expect(Expression.property("aProperty").isNullOrMissing().toString(), equals("property<aProperty>|isNullOrMissing|"));
    });
    test("lessThan()", () {
      expect(Expression.doubleValue(2.0).lessThan(Expression.doubleValue(16.0)).toString(), equals("double<2.0>|lessThan(double<16.0>|)|"));
    });
    test("lessThanOrEqualTo()", () {
      expect(Expression.doubleValue(2.0).lessThanOrEqualTo(Expression.doubleValue(16.0)).toString(), equals("double<2.0>|lessThanOrEqualTo(double<16.0>|)|"));
    });
    test("like()", () {
      expect(Expression.doubleValue(2.0).like(Expression.doubleValue(2.0)).toString(), equals("double<2.0>|like(double<2.0>|)|"));
    });
    test("like()", () {
      expect(Expression.doubleValue(2.0).modulo(Expression.doubleValue(2.0)).toString(), equals("double<2.0>|modulo(double<2.0>|)|"));
    });
    test("multiply()", () {
      expect(Expression.doubleValue(3.0).multiply(Expression.doubleValue(2.0)).toString(), equals("double<3.0>|multiply(double<2.0>|)|"));
    });
    test("notEqualTo()", () {
      expect(Expression.doubleValue(3.0).notEqualTo(Expression.doubleValue(2.0)).toString(), equals("double<3.0>|notEqualTo(double<2.0>|)|"));
    });
    test("notNullOrMissing()", () {
      expect(Expression.doubleValue(3.0).notNullOrMissing().toString(), equals("double<3.0>|notNullOrMissing|"));
    });
    test("or()", () {
      expect(Expression.booleanValue(true).or(Expression.booleanValue(false)).toString(), equals("bool<true>|or(bool<false>|)|"));
    });
    test("regex()", () {
      expect(Expression.string("Hello World!").regex(Expression.string(" ")).toString(), equals("string<Hello World!>|regex(string< >|)|"));
    });
    test("subtract()", () {
      expect(Expression.string("Hello World!").subtract(Expression.string(" ")).toString(), equals("string<Hello World!>|subtract(string< >|)|"));
    });
  });
}