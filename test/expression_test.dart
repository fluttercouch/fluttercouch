import 'dart:collection';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/query/expression/expression.dart';

void main() {
  group("Value building factory", () {
    test("booleanValue()", () {
      expect(Expression
          .booleanValue(true)
          .internalExpressionStack,
          equals(Queue<Map<String, bool>>()
            ..addLast({"booleanValue": true})));
    });
    test("doubleValue()", () {
      expect(
          Expression
              .doubleValue(1452.45212)
              .internalExpressionStack,
          equals(Queue<Map<String, double>>()
            ..addLast({"doubleValue": 1452.45212})));
    });
    test("intValue()", () {
      expect(Expression
          .intValue(1452)
          .internalExpressionStack,
          equals(Queue<Map<String, int>>()
            ..addLast({"intValue": 1452})));
    });
    test("negated()", () {
      expect(
          Expression
              .negated(Expression.booleanValue(true))
              .internalExpressionStack,
          equals(Queue<Map<String, dynamic>>()
            ..addLast({
              "negated": Expression
                  .booleanValue(true)
                  .internalExpressionStack
            })));
    });
    test("not()", () {
      expect(
          Expression
              .not(Expression.booleanValue(false))
              .internalExpressionStack,
          equals(Queue<Map<String, dynamic>>()
            ..addLast({
              "not": Expression
                  .booleanValue(false)
                  .internalExpressionStack
            })));
    });
    test("property()", () {
      expect(
          Expression
              .property("aPropertyName")
              .internalExpressionStack,
          equals(Queue<Map<String, String>>()
            ..addLast({"property": "aPropertyName"})));
    });
    test("string()", () {
      expect(Expression
          .string("aString")
          .internalExpressionStack,
          equals(Queue<Map<String, String>>()
            ..addLast({"string": "aString"})));
    });
    test("value()", () {
      expect(Expression
          .value(54.12)
          .internalExpressionStack,
          equals(Queue<Map<String, dynamic>>()
            ..addLast({"value": 54.12})));
    });

    group("Json conversion", () {
      test("simple json conversion", () {
        Expression expression = Expression.property("SDK").equalTo(
            Expression.string("SDK"));
        expect(jsonEncode(expression),
            '"[{\\"property\\":\\"SDK\\"},{\\"equalTo\\":[{\\"string\\":\\"SDK\\"}]}]"');
      });
    });
  });
}
