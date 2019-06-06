import 'package:fluttercouch/query/expression/expression.dart';

class Join {
  List<Map<String, dynamic>> _internalStack = List();

  Join._internal(String selector, String _dataSource, {String as}) {
    if (as != null) {
      this._internalStack.add({selector: _dataSource, "as": as});
    } else {
      this._internalStack.add({selector: _dataSource});
    }
  }

  Join on(Expression _expression) {
    this._internalStack.add({"on": _expression});
    return this;
  }

  factory Join.join(String _dataSource, {String as}) {
    return Join._internal("join", _dataSource, as: as);
  }

  factory Join.crossJoin(String _dataSource, {String as}) {
    return Join._internal("crossJoin", _dataSource, as: as);
  }

  factory Join.innerJoin(String _dataSource, {String as}) {
    return Join._internal("innerJoin", _dataSource, as: as);
  }

  factory Join.leftJoin(String _dataSource, {String as}) {
    return Join._internal("leftJoin", _dataSource, as: as);
  }

  factory Join.leftOuterJoin(String _dataSource, {String as}) {
    return Join._internal("leftOuterJoin", _dataSource, as: as);
  }

  toJson() {
    return _internalStack;
  }
}
