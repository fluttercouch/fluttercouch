import 'select.dart';
import 'select_result.dart';

class QueryBuilder {
  static Select select(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query.internalOptions["selectDistinct"] = false;
    query.internalOptions["selectResult"] = _selectResult;
    return query;
  }

  static Select selectDistinct(List<SelectResultProtocol> _selectResult) {
    var query = Select();
    query.internalOptions["selectDistinct"] = true;
    query.internalOptions["selectResult"] = _selectResult;
    return query;
  }
}
