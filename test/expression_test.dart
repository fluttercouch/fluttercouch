import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() {
  group("Value building factory", () {
    Expression boolExpr = Expression.booleanValue(true);
    test("booleanValue()", () {
      expect(boolExpr.toJson(), [
        {"booleanValue": true}
      ]);
    });
    Expression doubleExpr = Expression.doubleValue(1452.45212);
    test("doubleValue()", () {
      expect(doubleExpr.toJson(), [
        {"doubleValue": 1452.45212}
      ]);
    });
    Expression intExpr = Expression.intValue(1452);
    test("intValue()", () {
      expect(intExpr.toJson(), [
        {"intValue": 1452}
      ]);
    });
    Expression negatedExpr = Expression.negated(boolExpr);
    test("negated()", () {
      expect(negatedExpr.toJson(), [
        {
          "negated": [
            {"booleanValue": true}
          ]
        }
      ]);
    });

    Expression notExpr = Expression.not(boolExpr);
    test("not()", () {
      expect(notExpr.toJson(), [
        {
          "not": [
            {"booleanValue": true}
          ]
        }
      ]);
    });
    Expression propExpr = Expression.property("aPropertyName");
    test("property()", () {
      expect(propExpr.toJson(), [
        {"property": "aPropertyName"}
      ]);
    });
    Expression stringExpr = Expression.string("aString");
    test("string()", () {
      expect(stringExpr.toJson(), [
        {"string": "aString"}
      ]);
    });
    Expression valueExpr = Expression.value(54.12);
    test("value()", () {
      expect(valueExpr.toJson(), [
        {"value": 54.12}
      ]);
    });

    test("multiply()", () {
      expect(intExpr.multiply(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'multiply': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("divide()", () {
      expect(intExpr.divide(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'divide': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("modulo()", () {
      expect(intExpr.modulo(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'modulo': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("add()", () {
      expect(intExpr.add(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'add': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("subtract()", () {
      expect(intExpr.subtract(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'subtract': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("lessThan()", () {
      expect(intExpr.lessThan(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'lessThan': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("lessThanOrEqualTo()", () {
      expect(intExpr.lessThanOrEqualTo(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'lessThanOrEqualTo': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("greaterThan()", () {
      expect(intExpr.greaterThan(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'greaterThan': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("greaterThanOrEqualTo()", () {
      expect(intExpr.greaterThanOrEqualTo(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'greaterThanOrEqualTo': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("equalTo()", () {
      expect(intExpr.equalTo(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'equalTo': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("notEqualTo()", () {
      expect(intExpr.notEqualTo(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'notEqualTo': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("regex()", () {
      expect(intExpr.regex(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'regex': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("is()", () {
      expect(intExpr.iS(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'is': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("isNot()", () {
      expect(intExpr.isNot(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'isNot': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("isNullOrMissing()", () {
      expect(intExpr.isNullOrMissing().toJson(), [
        {'intValue': 1452},
        {'isNullOrMissing': null}
      ]);
    });

    test("notNullOrMissing()", () {
      expect(intExpr.notNullOrMissing().toJson(), [
        {'intValue': 1452},
        {'notNullOrMissing': null}
      ]);
    });

    test("and()", () {
      expect(intExpr.and(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'and': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("or()", () {
      expect(intExpr.or(intExpr).toJson(), [
        {'intValue': 1452},
        {
          'or': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("between()", () {
      expect(intExpr.between(intExpr, intExpr).toJson(), [
        {'intValue': 1452},
        {
          'between': [
            {'intValue': 1452}
          ],
          'and': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("in()", () {
      expect(intExpr.iN([intExpr]).toJson(), [
        {'intValue': 1452},
        {
          'in': [
            [
              {'intValue': 1452}
            ]
          ]
        }
      ]);
    });

    group("Json conversion", () {
      test("simple json conversion", () {
        Expression expression =
            Expression.property("SDK").equalTo(Expression.string("SDK"));
        expect(jsonEncode(expression),
            '[{"property":"SDK"},{"equalTo":[{"string":"SDK"}]}]');
      });
    });
  });
}
