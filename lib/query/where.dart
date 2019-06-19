import 'query.dart';
import 'group_by.dart';
import 'limit.dart';
import 'order_by.dart';
import 'ordering.dart';

import 'expression/expression.dart';

class Where extends Query {
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

  GroupBy groupBy(List<Expression> expressionList) {
    var resultQuery = new GroupBy();
    resultQuery.internalOptions = this.options;
    resultQuery.internalOptions["groupBy"] = expressionList;
    return resultQuery;
  }
}
