class Document {
  Map<String, dynamic> _internalState;

  Document(Map<dynamic, dynamic> _map) {
    _internalState = _stringMapFromDynamic(_map);
  }

  Map<String, dynamic> _stringMapFromDynamic(Map<dynamic, dynamic> _map) {
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

  Map<String, dynamic> toMap() {
    return _internalState;
  }
}