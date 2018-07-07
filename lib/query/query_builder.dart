import 'package:fluttercouch/query/select.dart';

import 'select_result.dart';

class QueryBuilder {
  static Select select(List<SelectResult> _selectResult) {
    var query = Select();
    query.options["selectDistinct"] = false;
    query.options["selectResult"] = _selectResult;
    return query;
  }

  static Select selectDistinct(List<SelectResult> _selectResult) {
    var query = Select();
    query.options["selectDistinct"] = true;
    query.options["selectResult"] = _selectResult;
    return query;
  }
}
