import 'package:fluttercouch/query/expression/expression.dart';
import 'package:fluttercouch/query/limit.dart';
import 'package:fluttercouch/query/order_by.dart';
import 'package:fluttercouch/query/ordering.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/query.dart';

class Having extends Query {
  Having() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = new Limit();
    resultQuery.options = this.options;
    resultQuery.options["limit"] = expression;
    if (offset != null) {
      resultQuery.options["offset"] = offset;
    }
    return resultQuery;
  }

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = new OrderBy();
    resultQuery.options = this.options;
    resultQuery.options["orderBy"] = orderingList;
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
