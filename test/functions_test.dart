import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() {
  group("Value building factory", () {
    Expression intExpr = Expression.intValue(1452);

    test("abs()", () {
      expect(Functions.abs(intExpr).toJson(), [
        {
          'abs': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("acos()", () {
      expect(Functions.acos(intExpr).toJson(), [
        {
          'acos': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("asin()", () {
      expect(Functions.asin(intExpr).toJson(), [
        {
          'asin': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("atan()", () {
      expect(Functions.atan(intExpr).toJson(), [
        {
          'atan': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("abs()", () {
      expect(Functions.atan2(intExpr, intExpr).toJson(), [
        {
          'atan2': [
            {'intValue': 1452}
          ],
          'y': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("avg()", () {
      expect(Functions.avg(intExpr).toJson(), [
        {
          'avg': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("ceil()", () {
      expect(Functions.ceil(intExpr).toJson(), [
        {
          'ceil': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("contains()", () {
      expect(Functions.contains(intExpr, intExpr).toJson(), [
        {
          'contains': [
            {'intValue': 1452}
          ],
          'y': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("cos()", () {
      expect(Functions.cos(intExpr).toJson(), [
        {
          'cos': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("count()", () {
      expect(Functions.count(intExpr).toJson(), [
        {
          'count': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("degrees()", () {
      expect(Functions.degrees(intExpr).toJson(), [
        {
          'degrees': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("e()", () {
      expect(Functions.e().toJson(), [
        {'e': null}
      ]);
    });

    test("exp()", () {
      expect(Functions.exp(intExpr).toJson(), [
        {
          'exp': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("floor()", () {
      expect(Functions.floor(intExpr).toJson(), [
        {
          'floor': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("length()", () {
      expect(Functions.length(intExpr).toJson(), [
        {
          'length': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("ln()", () {
      expect(Functions.ln(intExpr).toJson(), [
        {
          'ln': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("log()", () {
      expect(Functions.log(intExpr).toJson(), [
        {
          'log': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("lower()", () {
      expect(Functions.lower(intExpr).toJson(), [
        {
          'lower': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("ltrim()", () {
      expect(Functions.ltrim(intExpr).toJson(), [
        {
          'ltrim': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("max()", () {
      expect(Functions.max(intExpr).toJson(), [
        {
          'max': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("min()", () {
      expect(Functions.min(intExpr).toJson(), [
        {
          'min': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("pi()", () {
      expect(Functions.pi().toJson(), [
        {'pi': null}
      ]);
    });

    test("power()", () {
      expect(Functions.power(intExpr, intExpr).toJson(), [
        {
          'power': [
            {'intValue': 1452}
          ],
          'exponent': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("radians()", () {
      expect(Functions.radians(intExpr).toJson(), [
        {
          'radians': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("round()", () {
      expect(Functions.round(intExpr).toJson(), [
        {
          'round': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("roundDigits()", () {
      expect(Functions.round(intExpr, digits: intExpr).toJson(), [
        {
          'round': [
            {'intValue': 1452}
          ],
          'digits': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("rtrim()", () {
      expect(Functions.rtrim(intExpr).toJson(), [
        {
          'rtrim': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("sign()", () {
      expect(Functions.sign(intExpr).toJson(), [
        {
          'sign': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("sin()", () {
      expect(Functions.sin(intExpr).toJson(), [
        {
          'sin': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("sqrt()", () {
      expect(Functions.sqrt(intExpr).toJson(), [
        {
          'sqrt': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("sum()", () {
      expect(Functions.sum(intExpr).toJson(), [
        {
          'sum': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("tan()", () {
      expect(Functions.tan(intExpr).toJson(), [
        {
          'tan': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("trim()", () {
      expect(Functions.trim(intExpr).toJson(), [
        {
          'trim': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("trunc()", () {
      expect(Functions.trunc(intExpr).toJson(), [
        {
          'trunc': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("truncDigits()", () {
      expect(Functions.trunc(intExpr, digits: intExpr).toJson(), [
        {
          'trunc': [
            {'intValue': 1452}
          ],
          'digits': [
            {'intValue': 1452}
          ]
        }
      ]);
    });

    test("upper()", () {
      expect(Functions.upper(intExpr).toJson(), [
        {
          'upper': [
            {'intValue': 1452}
          ]
        }
      ]);
    });
  });
}
