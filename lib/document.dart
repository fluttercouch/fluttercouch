import 'mutable_document.dart';

class Document {
  Map<String, dynamic> internalState;
  String id;

  Document([Map<dynamic, dynamic> _map, String _id]) {
    if (_map != null) {
      internalState = stringMapFromDynamic(_map);
    } else {
      internalState = Map<String, dynamic>();
    }

    _id != null ? this.id = _id : _id = "random UUID";
  }

  Map<String, dynamic> stringMapFromDynamic(Map<dynamic, dynamic> _map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(_map);
  }

  bool contains(String key) {
    if (internalState != null &&
        internalState.isNotEmpty &&
        internalState.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  int count() {
    return internalState.length;
  }

  bool getBoolean(String key) {
    Object _result = getValue(key);
    return _result is bool ? _result : null;
  }

  double getDouble(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result;
    } else if (_result is int) {
      return _result.toDouble();
    } else {
      return null;
    }
  }

  int getInt(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result.toInt();
    } else if (_result is int) {
      return _result;
    } else {
      return null;
    }
  }

  List<String> getKeys() {
    if (internalState != null) {
      return internalState.keys;
    } else {
      return List<String>();
    }
  }

  String getString(String key) {
    Object _result = getValue(key);
    return _result is String ? _result : "";
  }

  Object getValue(String key) {
    if (contains(key)) {
      return internalState[key] as Object;
    } else {
      return null;
    }
  }

  List<T> getList<T>(String key) {
    List<dynamic> _result = getValue(key);
    if (_result != null) {
      return List.castFrom<dynamic, T>(_result);
    } else {
      return List<T>();
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
      return List<Map<K,V>>();
    }
  }

  Map<K, V> getMap<K, V>(String key) {
    Map<dynamic, dynamic> _result = getValue(key);
    if (_result != null) {
      return Map.castFrom<dynamic, dynamic, K, V>(_result);
    } else {
      return Map<K, V>();
    }
  }

  Map<String, dynamic> toMap() {
    return internalState;
  }

  MutableDocument toMutable() {
    return MutableDocument(map: internalState, id: id);
  }

  String getId() {
    return id;
  }

  bool isNotEmpty() {
    return internalState.isNotEmpty;
  }

  bool isNotNull() {
    return internalState != null;
  }

  bool isEmpty() {
    return internalState.isEmpty;
  }
}
