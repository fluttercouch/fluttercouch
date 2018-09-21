import 'package:fluttercouch/query/from.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/query.dart';

class Select extends Query {
  Select() {
    super.options = new Map<String, dynamic>();
    super.param = new Parameters();
  }

  From from(String databaseName) {
    var resultQuery = new From();
    resultQuery.options = this.options;
    options["from"] = databaseName;
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
