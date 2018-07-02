import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:fluttercouch/query/from.dart';
import 'package:fluttercouch/query/select.dart';
import 'package:fluttercouch/query/query_builder.dart';
import 'package:fluttercouch/query/select_result.dart';
import 'package:fluttercouch/query/expression.dart';
import 'package:fluttercouch/query/where.dart';

void main() {
  group("Query from QueryBuilder.select()",() {
    Select query = QueryBuilder.select(SelectResult.all());
    test("contains selectDistinct option", () {
      expect(query.options, contains("selectDistinct"));
    });
    test("the selectDistinct option is setted to false", () {
      expect(query.options["selectDistinct"], equals("false"));
    });
  });

  group("Query from QueryBuilder.selectDistinct()", () {
    Select query = QueryBuilder.selectDistinct(SelectResult.all());
    test("contains selectDistinct option", () {
      expect(query.options, contains("selectDistinct"));
    });
    test("the selectDistinct option is setted to true", () {
      expect(query.options["selectDistinct"], equals("true"));
    });
  });

  test("SelectResult.all() set the query option selectResultFromAll to true", () {
    Select query = QueryBuilder.select(SelectResult.all());
    expect(query.options["selectResultsFromAll"], equals("true"));
  });

  test("Select.from() sets a databaseName options and returns a From query", () {
    const DB_NAME = "database_name";
    From query = QueryBuilder.select(SelectResult.all()).from(DB_NAME);
    expect(query.options["databaseName"], equals(DB_NAME));
  });

  group("Starter code query set", () {
    Where query;
    setUp(() {
      query = QueryBuilder.select(SelectResult.all())
          .from("aDatabaseName")
          .where(Expression.property("type").equalTo(Expression.string("SDK")));
    });
    test("databaseName set", () {
      expect(query.options["databaseName"], equals("aDatabaseName"));
    });
    test("where option created", () {
      expect(query.options, contains("where"));
    });
    test("expression assigned to where option", () {
      expect(query.options["where"], equals("property<type>|equalTo(string<SDK>|)|"));
    });
  });
}