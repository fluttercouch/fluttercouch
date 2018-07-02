import 'package:fluttercouch/query/expression.dart';
import 'package:fluttercouch/query/limit.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';

import 'query.dart';
import 'result.dart';

class OrderBy extends Query {

  OrderBy() {
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
}