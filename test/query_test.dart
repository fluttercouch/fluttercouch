import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/query/array_function.dart';
import 'package:fluttercouch/query/expression/expression.dart';
import 'package:fluttercouch/query/expression/meta.dart';
import 'package:fluttercouch/query/functions.dart';
import 'package:fluttercouch/query/join.dart';
import 'package:fluttercouch/query/ordering.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:fluttercouch/query/query_builder.dart';
import 'package:fluttercouch/query/select_result.dart';

void main() {
  group("Query creation", () {
    test("Select query", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("name"),
        SelectResult.property("type"),
      ]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"name"}],[{"property":"type"}]]}');
    });

    test("SelectFrom", () {
      Query query = QueryBuilder.select([SelectResult.all()]).from("database");
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"string":"all"}]],"from":"database"}');
    });

    test("SelectFromWhere", () {
      Query query = QueryBuilder
          .select([SelectResult.all()])
          .from("database")
          .where(
          Expression.property("type").equalTo(Expression.string("hotel")));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"string":"all"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}]}');
    });

    test("SelectFromWhereOrderBy", () {
      Query query = QueryBuilder
          .select([SelectResult.all()])
          .from("database")
          .where(
          Expression.property("type").equalTo(Expression.string("hotel")))
          .orderBy([Ordering.expression(Meta.id)]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"string":"all"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"orderBy":[{"meta":"id"}]}');
    });

    test("SelectFromWhereLimit", () {
      Query query = QueryBuilder
          .select([SelectResult.all()])
          .from("database")
          .where(
          Expression.property("type").equalTo(Expression.string("hotel")))
          .limit(Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"string":"all"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"limit":[{"intValue":10}]}');
    });

    test("ArrayFunction", () {
      Query query = QueryBuilder
          .select([
        SelectResult.expression(Meta.id),
        SelectResult.property("name"),
        SelectResult.property("public_linkes")
      ])
          .from("Database")
          .where(Expression
          .property("type")
          .equalTo(Expression.string("hotel"))
          .and(ArrayFunction.contains(Expression.property("public_likes"),
          Expression.string("Armani Langworth"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"name"}],[{"property":"public_linkes"}]],"from":"Database","where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]},{"and":[]}]}');
    });

    test("In", () {
      Query query = QueryBuilder
          .select([SelectResult.property("name")])
          .from("database")
          .where(Expression
          .property("country")
          .In([Expression.string("Latvia"), Expression.string("usa")]).and(
          Expression
              .property("type")
              .equalTo(Expression.string("airport"))))
          .orderBy([Ordering.property("name")]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"}]],"from":"database","where":[{"property":"country"},{"in":[[{"string":"Latvia"}],[{"string":"usa"}]]},{"and":[{"property":"type"},{"equalTo":[{"string":"airport"}]}]}],"orderBy":[{"property":"name"}]}');
    });

    test("like", () {
      Query query = QueryBuilder
          .select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ])
          .from("database")
          .where(Expression
          .property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression
          .property("type")
          .like(Expression.string("Royal Engineers Museum"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"type"},{"like":[{"string":"Royal Engineers Museum"}]}]}]}');
    });

    test("regex", () {
      Query query = QueryBuilder
          .select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ])
          .from("database")
          .where(Expression
          .property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression
          .property("name")
          .regex(Expression.string("\\bEng.*r\\b"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"name"},{"regex":[{"string":"\\\\bEng.*r\\\\b"}]}]}]}');
    });

    test("join", () {
      Query query = QueryBuilder
          .select([
        SelectResult
            .expression(Expression.property("name").from("airline")),
        SelectResult
            .expression(Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult
            .expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.join("database", as: "route").on(Meta.id
          .from("airline")
          .equalTo(Expression.property("airlineid").from("route"))))
          .where(Expression
          .property("type")
          .from("route")
          .equalTo(Expression.string("route"))
          .and(Expression
          .property("type")
          .from("airline")
          .equalTo(Expression.string("airline")))
          .and(Expression
          .property("sourceairport")
          .from("route")
          .equalTo(Expression.string("RIX"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":"airline","joins":[{"join":"database","as":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"where":[{"property":"type"},{"from":"route"},{"equalTo":[{"string":"route"}]},{"and":[{"property":"type"},{"from":"airline"},{"equalTo":[{"string":"airline"}]}]},{"and":[{"property":"sourceairport"},{"from":"route"},{"equalTo":[{"string":"RIX"}]}]}]}');
    });

    test("groupBy", () {
      Query query = QueryBuilder
          .select([
        SelectResult.expression(Functions.count(Expression.string("*"))),
        SelectResult.property("country"),
        SelectResult.property("tz")
      ])
          .from("database")
          .where(Expression
          .property("type")
          .equalTo(Expression.string("airport"))
          .and(Expression
          .property("geo.alt")
          .greaterThanOrEqualTo(Expression.intValue(300))))
          .groupBy([Expression.property("country"), Expression.property("tz")])
          .orderBy([
        Ordering
            .expression(Functions.count(Expression.string("*")))
            .descending()
      ]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"count":[{"string":"*"}]}],[{"property":"country"}],[{"property":"tz"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"airport"}]},{"and":[{"property":"geo.alt"},{"greaterThanOrEqualTo":[{"intValue":300}]}]}],"groupBy":[[{"property":"country"}],[{"property":"tz"}]],"orderBy":[{"count":[{"string":"*"}]},{"orderingSortOrder":"descending"}]}');
    });

    test("orderBy", () {
      Query query = QueryBuilder
          .select(
          [SelectResult.expression(Meta.id), SelectResult.property("name")])
          .from("database")
          .where(
          Expression.property("type").equalTo(Expression.string("hotel")))
          .orderBy([Ordering.property("name").ascending()])
          .limit(Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}],[{"property":"name"}]],"from":"database","where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"orderBy":[{"property":"name"},{"orderingSortOrder":"ascending"}],"limit":[{"intValue":10}]}');
    });
  });
}
