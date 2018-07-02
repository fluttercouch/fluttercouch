import 'package:fluttercouch/query/select_result_from.dart';

import 'select.dart';
import 'select_result.dart';

class QueryBuilder {
  static Select select(SelectResult result) {
    var query = Select();
    query.options["selectDistinct"] = "false";
    if (result is SelectResult_From) {
      query.options["selectResultsFromAll"] = result.selectResultFromAll;
    }
    return query;
  }

  static Select selectDistinct(SelectResult result) {
    var query = Select();
    query.options["selectDistinct"] = "true";
    if (result is SelectResult_From) {
      query.options["selectResultsFromAll"] = result.selectResultFromAll;
    }
    return query;
  }
}