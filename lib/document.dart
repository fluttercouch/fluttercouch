import 'mutable_document.dart';

class Document {
  Map<String, dynamic> _internalState;
  String _id;

  Document([Map<dynamic, dynamic> _map, String _id]) {
    if (_map != null) {
      _internalState = stringMapFromDynamic(_map);
    } else {
      _internalState = Map<String, dynamic>();
    }

    _id != null ? this._id = _id : _id = "random UUID";
  }

  Map<String, dynamic> stringMapFromDynamic(Map<dynamic, dynamic> _map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(_map);
  }

  bool contains(String key) {
    if (_internalState != null &&
        _internalState.isNotEmpty &&
        _internalState.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  int count() {
    return _internalState.length;
  }

  double getDouble(String key) {
    Object _result = getValue(key);
    return _result is double ? _result : null;
  }

  int getInt(String key) {
    Object _result = getValue(key);
    return _result is int ? _result : null;
  }

  List<String> getKeys() {
    if (_internalState != null) {
      return _internalState.keys;
    } else {
      return null;
    }
  }

  String getString(String key) {
    Object _result = getValue(key);
    return _result is String ? _result : null;
  }

  Object getValue(String key) {
    if (contains(key)) {
      return _internalState[key] as Object;
    } else {
      return null;
    }
  }

  List<T> getList<T>(String key) {
    List<dynamic> _result = getValue(key);
    if (_result != null) {
      return List.castFrom<dynamic, T>(_result);
    } else {
      return null;
    }
  }

  List<Map<K, V>> getListOfMap<K, V>(String key) {
    List<dynamic> _result = getValue(key);
    if (_result != null) {
      return _result
          .cast<Map<dynamic, dynamic>>()
          .map((item) => item.cast<K, V>())
          .toList();
    } else {
      return null;
    }
  }

  Map<K, V> getMap<K, V>(String key) {
    Map<dynamic, dynamic> _result = getValue(key);
    if (_result != null) {
      return Map.castFrom<dynamic, dynamic, K, V>(_result);
    } else {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return _internalState;
  }

  MutableDocument toMutable() {
    return MutableDocument(_internalState);
  }

  String getId() {
    return _id;
  }

  bool isNotEmpty() {
    return _internalState.isNotEmpty;
  }

  bool isEmpty() {
    return _internalState.isEmpty;
  }
}
