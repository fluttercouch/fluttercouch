import 'dart:collection';

import 'result.dart';

class ResultSet extends Object with IterableMixin<Result> {
  List<Result> _internalState;

  ResultSet(List<Result> _list) {
    this._internalState = _list;
  }

  List<Result> allResult() {
    return _internalState;
  }

  Iterator<Result> get iterator => _internalState.iterator;
}
