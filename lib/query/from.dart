import 'query.dart';
import 'group_by.dart';
import 'join.dart';
import 'joins.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'where.dart';

import 'expression/expression.dart';

class From extends Query {
  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["where"] = expression;
    return resultQuery;
  }

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = new GroupBy();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["groupBy"] = expressionList;
    return resultQuery;
  }

  Joins join(Join expression) {
    var resultQuery = new Joins();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["joins"] = expression;
    return resultQuery;
  }

  Limit limit(Expression expression, {Expression offset}) {
    var resultQuery = new Limit();
    resultQuery.internalOptions = this.options;
    if (offset != null) {
      resultQuery.internalOptions["limit"] = [expression, offset];
    } else {
      resultQuery.internalOptions["limit"] = [expression];
    }
    return resultQuery;
  }

  OrderBy orderBy(List<Ordering> orderingList) {
    var resultQuery = new OrderBy();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["orderBy"] = orderingList;
    return resultQuery;
  }
}
