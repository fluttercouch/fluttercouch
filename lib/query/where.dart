import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/result_set.dart';

import 'query.dart';
import 'result.dart';

class Where extends Query {

  Where() {
    this.options = new Map<String, String>();
    this.param = new Parameters();
  }
}