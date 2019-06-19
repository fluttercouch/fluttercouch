import 'from.dart';
import 'query.dart';

class Select extends Query {
  From from(String databaseName, {String as}) {
    var resultQuery = new From();
    resultQuery.internalOptions = this.options;
    if (as != null) {
      resultQuery.internalOptions["from"] = {
        "database": databaseName,
        "as": as
      };
    } else {
      resultQuery.internalOptions["from"] = {"database": databaseName};
    }
    return resultQuery;
  }
}
