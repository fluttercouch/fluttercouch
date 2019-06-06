import 'package:fluttercouch/query/expression/expression.dart';
import 'package:fluttercouch/query/group_by.dart';
import 'package:fluttercouch/query/join.dart';
import 'package:fluttercouch/query/joins.dart';
import 'package:fluttercouch/query/limit.dart';
import 'package:fluttercouch/query/order_by.dart';
import 'package:fluttercouch/query/ordering.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:fluttercouch/query/where.dart';

class From extends Query {
  From() {
    this.options = new Map<String, dynamic>();
    this.param = new Parameters();
  }

  from(String dbName) {
    this.options['databaseName'] = dbName;
  }

  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.options = this.options;
    resultQuery.options["where"] = expression;
    return resultQuery;
  }

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = new GroupBy();
    resultQuery.options = this.options;
    resultQuery.options["groupBy"] = expressionList;
    return resultQuery;
  }

  Joins join(Join expression) {
    var resultQuery = new Joins();
    resultQuery.options = this.options;
    resultQuery.options["joins"] = expression;
    return resultQuery;
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
