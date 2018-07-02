import 'package:fluttercouch/query/expression.dart';
import 'package:fluttercouch/query/limit.dart';
import 'package:fluttercouch/query/order_by.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';
import 'package:fluttercouch/query/where.dart';

import 'query.dart';
import 'result.dart';

class Joins extends Query {

  Joins() {
    super.options = new Map<String, String>();
    super.param = new Parameters();
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

  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.options = super.options;
    resultQuery.options["where"] = expression.toString();
    return resultQuery;
  }
}