import 'dart:typed_data';

import 'mutable_document.dart';

/// Couchbase Lite document. The Document is immutable.
class Document {
  Document([Map<dynamic, dynamic> data, String id]) {
    if (data != null) {
      internalState = _stringMapFromDynamic(data);
    } else {
      internalState = Map<String, dynamic>();
    }

    _id = id;
  }

  Map<dynamic, dynamic> internalState;
  String _id;
  Map<String, Map<String, Uint8List>> attachments;

  /// The document's ID.
  String get id => _id;

  Map<String, dynamic> _stringMapFromDynamic(Map<dynamic, dynamic> _map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(_map);
  }

  /// Tests whether a property exists or not.
  /// This can be less expensive than value(forKey:), because it does not have to allocate an
  /// object for the property value.
  ///
  /// - Parameter key: The key.
  /// - Returns: True of the property exists, otherwise false.
  bool contains(String key) {
    if (internalState != null &&
        internalState.isNotEmpty &&
        internalState.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  /// The number of properties in the document.
  int count() {
    return internalState.length;
  }

  /// Gets a property's value as a boolean value.
  /// Returns true if the value exists, and is either `true` or a nonzero number.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Bool value.
  bool getBoolean(String key) {
    Object _result = getValue(key);

    if (_result is num) {
      return _result != 0;
    }

    return _result is bool ? _result : false;
  }

  /// Gets a property's value as a double value.
  /// Integers will be converted to double. The value `true` is returned as 1.0, `false` as 0.0.
  /// Returns 0.0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Double value.
  double getDouble(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result;
    } else if (_result is int) {
      return _result.toDouble();
    } else {
      return 0.0;
    }
  }

  /// Gets a property's value as an int value.
  /// Floating point values will be rounded. The value `true` is returned as 1, `false` as 0.
  /// Returns 0 if the property doesn't exist or does not have a numeric value.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Int value.
  int getInt(String key) {
    Object _result = getValue(key);
    if (_result is double) {
      return _result.toInt();
    } else if (_result is int) {
      return _result;
    } else {
      return 0;
    }
  }

  /// An array containing all keys, or an empty array if the document has no properties.
  List<String> getKeys() {
    if (internalState != null) {
      return internalState.keys.toList();
    } else {
      return List<String>();
    }
  }

  ///  Gets a property's value as a string.
  ///  Returns null if the property doesn't exist, or its value is not a string.
  ///
  /// - Parameter key: The key.
  /// - Returns: The String object or null.
  String getString(String key) {
    Object _result = getValue(key);
    return _result is String ? _result : null;
  }

  /// Gets a property's value. The value types are Blob, ArrayObject,
  /// DictionaryObject, Number, or String based on the underlying data type; or null
  /// if the value is null or the property doesn't exist.
  ///
  /// - Parameter key: The key.
  /// - Returns: The value or null.
  Object getValue(String key) {
    if (contains(key)) {
      return internalState[key] as Object;
    } else {
      return null;
    }
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  List<T> getList<T>(String key) {
    var _result = getValue(key);
    if (_result is List) {
      return List.from(List.castFrom<dynamic, T>(_result));
    }

    return null;
  }

  /// Get a property's value as a List Object, which is a mapping object of an array value.
  /// Returns null if the property doesn't exists, or its value is not an array.
  ///
  /// - Parameter key: The key.
  /// - Returns: The List Object object or null.
  List<T> getArray<T>(String key) => getList(key);

  /// Get a property's value as a Map Object, which is a mapping object of
  /// a dictionary value.
  /// Returns null if the property doesn't exists, or its value is not a dictionary.
  ///
  /// - Parameter key: The key.
  /// - Returns: The Map Object object or nil.
  Map<K, V> getMap<K, V>(String key) {
    var _result = getValue(key);
    if (_result is Map) {
      return Map.from(Map.castFrom<dynamic, dynamic, K, V>(_result));
    }

    return null;
  }

  /// Gets content of the current object as a Dictionary.
  ///
  /// - Returns: The Dictionary representing the content of the current object.
  Map<String, dynamic> toMap() {
    return Map.from(internalState);
  }

  /// Returns a mutable copy of the document.
  ///
  /// - Returns: The MutableDocument object.
  MutableDocument toMutable() {
    return MutableDocument(internalState, id);
  }
}
