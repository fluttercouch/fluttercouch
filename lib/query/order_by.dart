import 'expression/expression.dart';
import 'limit.dart';
import 'query.dart';

class OrderBy extends Query {
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
}
