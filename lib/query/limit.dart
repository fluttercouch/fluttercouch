import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';

import 'query.dart';
import 'result.dart';

class Limit extends Query {

  Limit() {
    super.options = new Map<String, String>();
    super.param = new Parameters();
  }
}