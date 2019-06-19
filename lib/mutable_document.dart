import 'document.dart';

class MutableDocument extends Document {
  MutableDocument([Map<dynamic, dynamic> data, String id]) : super(data, id) {
    this.id = id;
  }

  @override
  String id;

  /// Set a value for the given key. Allowed value types are Array, Map,
  /// Number types, null, String, Array Object, Map and nil.
  /// The Arrays and Maps must contain only the above types.
  /// TODO A Date object will be converted to an ISO-8601 format string.
  ///
  /// - Parameters:
  ///   - value: The value.
  ///   - key: The key.
  /// - Returns: The self object.
  void setValue(String key, Object value) {
    if (value != null) {
      super.internalState[key] = value;
    }
  }

  /// Set a List object for the given key.
  ///
  /// - Parameters:
  ///   - value: The List Object object.
  ///   - key: The key.
  void setList(String key, List<dynamic> value) {
    setValue(key, value);
  }

  /// Set a List object for the given key.
  ///
  /// - Parameters:
  ///   - value: The List Object object.
  ///   - key: The key.
  void setArray(String key, List<dynamic> value) => setList(key, value);

  /// Set a Map Object object for the given key. A nil value will be converted to an NSNull.
  ///
  /// - Parameters:
  ///   - value: The Map Object object.
  ///   - key: The key.
  void setMap(String key, Map<dynamic, dynamic> value) {
    setValue(key, value);
  }

  /// Set a boolean value for the given key.
  ///
  /// - Parameters:
  ///   - value: The boolean value.
  ///   - key: The key.
  void setBoolean(String key, bool value) {
    setValue(key, value);
  }

  /// Set a double value for the given key.
  ///
  /// - Parameters:
  ///   - value: The double value.
  ///   - key: The key.
  void setDouble(String key, double value) {
    setValue(key, value);
  }

  /// Set an int value for the given key.
  ///
  /// - Parameters:
  ///   - value: The int value.
  ///   - key: The key.
  void setInt(String key, int value) {
    setValue(key, value);
  }

  /// Set a String value for the given key.
  ///
  /// - Parameters:
  ///   - value: The String value.
  ///   - key: The Document object.
  void setString(String key, String value) {
    setValue(key, value);
  }

  /// Removes a given key and its value.
  ///
  /// - Parameter key: The key.
  void remove(String key) {
    super.internalState.remove(key);
  }

  /// Returns the same MutableDocument object.
  ///
  /// - Returns: The MutableDocument object.
  @override
  MutableDocument toMutable() {
    return this;
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  @override
  List<T> getList<T>(String key) {
    var _result = getValue(key);
    if (_result is List) {
      return List.castFrom<dynamic, T>(_result);
    }

    return null;
  }

  /// Get a property's value as a Map Object, which is a mapping object of
  /// a dictionary value.
  /// Returns nil if the property doesn't exists, or its value is not a dictionary.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Map Object object or nil.
  @override
  Map<K, V> getMap<K, V>(String key) {
    var _result = getValue(key);
    if (_result is Map) {
      return Map.castFrom<dynamic, dynamic, K, V>(_result);
    }

    return null;
  }
}
