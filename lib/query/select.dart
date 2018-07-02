import 'package:fluttercouch/query/from.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';

import 'query.dart';
import 'result.dart';

class Select extends Query {

  Select() {
    super.options = new Map<String, String>();
    super.param = new Parameters();
  }

  From from(String databaseName) {
    var resultQuery = new From();
    resultQuery.options = super.options;
    options["databaseName"] = databaseName;
    return resultQuery;
  }
}