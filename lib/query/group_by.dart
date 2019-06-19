import 'query.dart';
import 'having.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';

import 'expression/expression.dart';

class GroupBy extends Query {
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

  Having having(Expression expression) {
    var resultQuery = new Having();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["having"] = expression;
    return resultQuery;
  }
}
