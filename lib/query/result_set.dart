import 'dart:collection';

import 'result.dart';

class ResultSet extends Object with IterableMixin<Result> {
  ResultSet(List<Result> _list) {
    this._internalState = _list;
  }

  List<Result> _internalState;

  List<Result> allResults() => List.of(_internalState);

  @override
  Iterator<Result> get iterator => _internalState.iterator;
}
