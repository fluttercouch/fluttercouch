import 'package:fluttercouch/query/from.dart';
import 'package:fluttercouch/query/parameters.dart';
import 'package:fluttercouch/query/query.dart';

class Select extends Query {
  Select() {
    super.options = new Map<String, dynamic>();
    super.param = new Parameters();
  }

  From from(String databaseName, {String as}) {
    var resultQuery = new From();
    resultQuery.options = this.options;
    if (as != null) {
      options["from"] = {"database": databaseName, "as": as};
    } else {
      options["from"] = {"database": databaseName};
    }
    return resultQuery;
  }

  Map<String, dynamic> toJson() => options;
}
