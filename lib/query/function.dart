import 'dart:convert';

import 'package:fluttercouch/query/expression/expression.dart';

class Function {
  List<Map<String, dynamic>> _internalStack = List();

  Function._internal(String selector, String _dataSource, {String as}) {
    if (as != null) {
      this._internalStack.add({selector: _dataSource, "as": as});
    } else {
      this._internalStack.add({selector: _dataSource});
    }
  }

  Function on(Expression _expression) {
    this._internalStack.add({"on": _expression});
    return this;
  }

  factory Function.join(String _dataSource, {String as}) {
    return Function._internal("join", _dataSource, as: as);
  }

  factory Function.crossJoin(String _dataSource, {String as}) {
    return Function._internal("crossJoin", _dataSource, as: as);
  }

  factory Function.innerJoin(String _dataSource, {String as}) {
    return Function._internal("innerJoin", _dataSource, as: as);
  }

  factory Function.leftJoin(String _dataSource, {String as}) {
    return Function._internal("leftJoin", _dataSource, as: as);
  }

  factory Function.leftOuterJoin(String _dataSource, {String as}) {
    return Function._internal("leftOuterJoin", _dataSource, as: as);
  }

  toJson() {
    return json.encode(_internalStack);
  }
}
