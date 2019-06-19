import 'query.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';
import 'where.dart';

import 'expression/expression.dart';

class Joins extends Query {
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

  Where where(Expression expression) {
    var resultQuery = new Where();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["where"] = expression;
    return resultQuery;
  }
}
