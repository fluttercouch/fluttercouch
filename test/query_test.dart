import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/fluttercouch.dart';

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

    From baseQuery = QueryBuilder.select([SelectResult.all()]).from("database");

    Map<String, dynamic> baseJson = {
      "selectDistinct": false,
      "selectResult": [
        [
          {"property": null}
        ]
      ],
      "from": {"database": "database"}
    };
    Expression limitExpr = Expression.intValue(10);
    Map<String, dynamic> limitJson = {
      "limit": [
        [
          {"intValue": 10}
        ]
      ]
    };
    Expression offsetExpr = Expression.intValue(10);
    Map<String, dynamic> limitOffsetJson = {
      "limit": [
        [
          {"intValue": 10}
        ],
        [
          {"intValue": 10}
        ]
      ]
    };
    List<Ordering> orderByExpr = [Ordering.property("country")];
    Map<String, dynamic> orderByJson = {
      "orderBy": [
        [
          {"property": "country"}
        ]
      ]
    };

    test("SelectFrom", () {
      expect(json.encode(baseQuery), json.encode(baseJson));
    });

    test("SelectFromAs", () {
      Query query = QueryBuilder.selectDistinct(
              [SelectResult.expression(Meta.sequence.from("myAlias"))])
          .from("database", as: "myAlias");
      expect(json.encode(query),
          '{"selectDistinct":true,"selectResult":[[{"meta":"sequence"},{"from":"myAlias"}]],"from":{"database":"database","as":"myAlias"}}');
    });

    test("SelectFromWhere", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}]}');
    });

    test("SelectFromWhereOrderBy", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")))
          .orderBy([Ordering.expression(Meta.id)]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"orderBy":[[{"meta":"id"}]]}');
    });

    test("SelectFromWhereLimit", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")))
          .limit(Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"limit":[[{"intValue":10}]]}');
    });

    test("In", () {
      Query query = QueryBuilder.select([SelectResult.property("name")])
          .from("database")
          .where(Expression.property("country")
              .iN([Expression.string("Latvia"), Expression.string("usa")]).and(
                  Expression.property("type")
                      .equalTo(Expression.string("airport"))))
          .orderBy([Ordering.property("name")]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"country"},{"in":[[{"string":"Latvia"}],[{"string":"usa"}]]},{"and":[{"property":"type"},{"equalTo":[{"string":"airport"}]}]}],"orderBy":[[{"property":"name"}]]}');
    });

    test("like", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ]).from("database").where(Expression.property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression.property("type")
              .like(Expression.string("Royal Engineers Museum"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"type"},{"like":[{"string":"Royal Engineers Museum"}]}]}]}');
    });

    test("regex", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ]).from("database").where(Expression.property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression.property("name")
              .regex(Expression.string("\\bEng.*r\\b"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"name"},{"regex":[{"string":"\\\\bEng.*r\\\\b"}]}]}]}');
    });

    test("join", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.join("route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .where(Expression.property("type")
              .from("route")
              .equalTo(Expression.string("route"))
              .and(Expression.property("type")
                  .from("airline")
                  .equalTo(Expression.string("airline")))
              .and(Expression.property("sourceairport")
                  .from("route")
                  .equalTo(Expression.string("RIX"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"join":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"where":[{"property":"type"},{"from":"route"},{"equalTo":[{"string":"route"}]},{"and":[{"property":"type"},{"from":"airline"},{"equalTo":[{"string":"airline"}]}]},{"and":[{"property":"sourceairport"},{"from":"route"},{"equalTo":[{"string":"RIX"}]}]}]}');
    });

    test("joinAs", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.join("database", as: "route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .where(Expression.property("type")
              .from("route")
              .equalTo(Expression.string("route"))
              .and(Expression.property("type")
                  .from("airline")
                  .equalTo(Expression.string("airline")))
              .and(Expression.property("sourceairport")
                  .from("route")
                  .equalTo(Expression.string("RIX"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"join":"database","as":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"where":[{"property":"type"},{"from":"route"},{"equalTo":[{"string":"route"}]},{"and":[{"property":"type"},{"from":"airline"},{"equalTo":[{"string":"airline"}]}]},{"and":[{"property":"sourceairport"},{"from":"route"},{"equalTo":[{"string":"RIX"}]}]}]}');
    });

    test("crossJoin", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.crossJoin("route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .where(Expression.property("type")
              .from("route")
              .equalTo(Expression.string("route"))
              .and(Expression.property("type")
                  .from("airline")
                  .equalTo(Expression.string("airline")))
              .and(Expression.property("sourceairport")
                  .from("route")
                  .equalTo(Expression.string("RIX"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"crossJoin":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"where":[{"property":"type"},{"from":"route"},{"equalTo":[{"string":"route"}]},{"and":[{"property":"type"},{"from":"airline"},{"equalTo":[{"string":"airline"}]}]},{"and":[{"property":"sourceairport"},{"from":"route"},{"equalTo":[{"string":"RIX"}]}]}]}');
    });

    test("innerJoin", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.innerJoin("route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .limit(Expression.intValue(10), offset: Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"innerJoin":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"limit":[[{"intValue":10}],[{"intValue":10}]]}');
    });

    test("leftJoin", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.leftJoin("route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .limit(Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"leftJoin":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"limit":[[{"intValue":10}]]}');
    });

    test("leftOuterJoin", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.leftOuterJoin("route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .orderBy([Ordering.property("callsign")]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"leftOuterJoin":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"orderBy":[[{"property":"callsign"}]]}');
    });

    GroupBy groupBy = baseQuery.groupBy([Expression.property("country")]);
    Map<String, dynamic> groupByJson = Map.from(baseJson);
    groupByJson.addAll({
      "groupBy": [
        [
          {"property": "country"}
        ]
      ]
    });

    test("groupBy", () {
      expect(json.encode(groupBy), json.encode(groupByJson));
    });

    test("groupByLimit", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(limitJson);
      expect(json.encode(groupBy.limit(limitExpr)), json.encode(expected));
    });

    test("groupByLimitOffset", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(limitOffsetJson);
      expect(json.encode(groupBy.limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    test("groupByOrderBy", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(orderByJson);
      expect(json.encode(groupBy.orderBy(orderByExpr)), json.encode(expected));
    });

    Having having = groupBy.having(
        Expression.property("country").equalTo(Expression.string("US")));

    Map<String, dynamic> havingJson = Map.from(groupByJson);
    havingJson.addAll({
      "having": [
        {"property": "country"},
        {
          "equalTo": [
            {"string": "US"}
          ]
        }
      ]
    });

    test("having", () {
      Map expected = Map.from(havingJson);
      expect(json.encode(having), json.encode(expected));
    });

    test("havingLimit", () {
      Map expected = Map.from(havingJson);
      expected.addAll(limitJson);
      expect(json.encode(having.limit(limitExpr)), json.encode(expected));
    });

    test("havingLimitOffset", () {
      Map expected = Map.from(havingJson);
      expected.addAll(limitOffsetJson);
      expect(json.encode(having.limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    test("havingOrderBy", () {
      Map expected = Map.from(havingJson);
      expected.addAll(orderByJson);
      expect(json.encode(having.orderBy(orderByExpr)), json.encode(expected));
    });

    test("limit", () {
      Map expected = Map.from(baseJson);
      expected.addAll(limitJson);
      expect(json.encode(baseQuery.limit(limitExpr)), json.encode(expected));
    });

    test("orderBy", () {
      Map expected = Map.from(baseJson);
      expected.addAll(orderByJson);
      expect(
          json.encode(baseQuery.orderBy(orderByExpr)), json.encode(expected));
    });

    test("orderByLimit", () {
      Map expected = Map.from(baseJson);
      expected.addAll(orderByJson);
      expected.addAll(limitJson);
      expect(json.encode(baseQuery.orderBy(orderByExpr).limit(limitExpr)),
          json.encode(expected));
    });

    test("orderByLimitOffset", () {
      Map expected = Map.from(baseJson);
      expected.addAll(orderByJson);
      expected.addAll(limitOffsetJson);
      expect(
          json.encode(baseQuery
              .orderBy(orderByExpr)
              .limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    List<Ordering> orderByAscExpr = [Ordering.property("country").ascending()];
    Map<String, dynamic> orderByAscJson = {
      "orderBy": [
        [
          {"property": "country"},
          {"orderingSortOrder": "ascending"}
        ]
      ]
    };
    test("orderAscending", () {
      Map expected = Map.from(baseJson);
      expected.addAll(orderByAscJson);
      expect(json.encode(baseQuery.orderBy(orderByAscExpr)),
          json.encode(expected));
    });

    List<Ordering> orderByDescExpr = [
      Ordering.property("country").descending()
    ];
    Map<String, dynamic> orderByDescJson = {
      "orderBy": [
        [
          {"property": "country"},
          {"orderingSortOrder": "descending"}
        ]
      ]
    };
    test("orderDescending", () {
      Map expected = Map.from(baseJson);
      expected.addAll(orderByDescJson);
      expect(json.encode(baseQuery.orderBy(orderByDescExpr)),
          json.encode(expected));
    });

    Where whereExpr = baseQuery
        .where(Expression.property("country").equalTo(Expression.string("US")));
    Map<String, dynamic> whereJson = Map.from(baseJson);
    whereJson.addAll({
      "where": [
        {"property": "country"},
        {
          "equalTo": [
            {"string": "US"}
          ]
        }
      ]
    });

    test("whereLimitOffset", () {
      Map expected = Map.from(whereJson);
      expected.addAll(limitOffsetJson);
      expect(json.encode(whereExpr.limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    test("whereGroupBy", () {
      Map expected = Map.from(whereJson);
      expected.addAll({
        "groupBy": [
          [
            {"property": "country"}
          ]
        ]
      });
      expect(json.encode(whereExpr.groupBy([Expression.property("country")])),
          json.encode(expected));
    });
  });

  group("Results", () {
    var map = {
      "int": 1,
      "bool": true,
      "list": [],
      "double": 1.2,
      "string": "test",
      "object": {}
    };
    Map<dynamic, dynamic> result = {
      "map": map,
      "list": [1]
    };

    var newResult = Result();
    newResult.setMap(result["map"]);
    newResult.setList(result["list"]);

    test("contains()", () {
      expect(newResult.contains("int"), true);
    });

    test("count()", () {
      expect(newResult.count(), map.length);
    });

    test("getList()", () {
      expect(newResult.getList(key: "list"), []);
    });

    test("getBoolean()", () {
      expect(newResult.getBoolean(key: "bool"), true);
    });

    test("getDouble()", () {
      expect(newResult.getDouble(key: "double"), 1.2);
    });

    test("getInt()", () {
      expect(newResult.getInt(key: "int"), 1);
    });

    test("getKeys()", () {
      expect(newResult.getKeys(), map.keys);
    });

    test("getString()", () {
      expect(newResult.getString(key: "string"), "test");
    });

    test("getValue()", () {
      expect(newResult.getValue(key: "int"), 1);
    });

    test("getValueIndex()", () {
      expect(newResult.getValue(index: 0), 1);
    });

    test("toList()", () {
      expect(newResult.toList(), [1]);
    });

    test("toMap()", () {
      expect(newResult.toMap(), map);
    });

    var results = ResultSet([newResult]);

    test("allResults()", () {
      expect(results.allResults(), [newResult]);
    });

    test("allResults()", () {
      expect(results.allResults(), [newResult]);
    });

    test("iterator", () {
      var itr = results.iterator;
      itr.moveNext();
      expect(itr.current, newResult);
    });
  });
}
