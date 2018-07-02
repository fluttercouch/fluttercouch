import 'package:fluttercouch/query/expression.dart';
import 'package:fluttercouch/query/group_by.dart';
import 'package:fluttercouch/query/joins.dart';
import 'package:fluttercouch/query/limit.dart';
import 'package:fluttercouch/query/order_by.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';
import 'package:fluttercouch/query/where.dart';
import 'result.dart';

import 'query.dart';

class From extends Query {

  From() {
    super.options = new Map<String, String>();
    super.param = new Parameters();
  }

  from(String dbName) {
    super.options['databaseName'] = dbName;
  }

  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.options = super.options;
    resultQuery.options["where"] = expression.toString();
    return resultQuery;
  }

  GroupBy groupBy(Expression expression) {
    var resultQuery = new GroupBy();
    resultQuery.options = super.options;
    resultQuery.options["groupBy"] = expression.toString();
    return resultQuery;
  }

  Joins join(Expression expression) {
    var resultQuery = new Joins();
    resultQuery.options = super.options;
    resultQuery.options["joins"] = expression.toString();
    return resultQuery;
  }

  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = new Limit();
    resultQuery.options = super.options;
    resultQuery.options["limit"] = expression.toString();
    if (offset != null) {
      resultQuery.options["offset"] = offset.toString();
    }
    return resultQuery;
  }

  OrderBy orderBy(Expression expression) {
    var resultQuery = new OrderBy();
    resultQuery.options = super.options;
    resultQuery.options["orderBy"] = expression.toString();
    return resultQuery;
  }
}