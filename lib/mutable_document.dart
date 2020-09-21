import 'blob.dart';
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
  MutableDocument setValue(String key, Object value) {
    if (value != null) {
      super.internalState[key] = value;
    }

    return this;
  }

  /// Set a List object for the given key.
  ///
  /// - Parameters:
  ///   - value: The List Object object.
  ///   - key: The key.
  MutableDocument setList(String key, List<dynamic> value) {
    return setValue(key, value);
  }

  /// Set a List object for the given key.
  ///
  /// - Parameters:
  ///   - value: The List Object object.
  ///   - key: The key.
  MutableDocument setArray(String key, List<dynamic> value) =>
      setList(key, value);

  /// Set a Map Object object for the given key. A nil value will be converted to an NSNull.
  ///
  /// - Parameters:
  ///   - value: The Map Object object.
  ///   - key: The key.
  MutableDocument setMap(String key, Map<dynamic, dynamic> value) {
    return setValue(key, value);
  }

  /// Set a boolean value for the given key.
  ///
  /// - Parameters:
  ///   - value: The boolean value.
  ///   - key: The key.
  MutableDocument setBoolean(String key, bool value) {
    return setValue(key, value);
  }

  /// Set a double value for the given key.
  ///
  /// - Parameters:
  ///   - value: The double value.
  ///   - key: The key.
  MutableDocument setDouble(String key, double value) {
    return setValue(key, value);
  }

  /// Set an int value for the given key.
  ///
  /// - Parameters:
  ///   - value: The int value.
  ///   - key: The key.
  MutableDocument setInt(String key, int value) {
    return setValue(key, value);
  }

  /// Set a String value for the given key.
  ///
  /// - Parameters:
  ///   - value: The String value.
  ///   - key: The Document object.
  MutableDocument setString(String key, String value) {
    return setValue(key, value);
  }

  /// Removes a given key and its value.
  ///
  /// - Parameter key: The key.
  MutableDocument remove(String key) {
    super.internalState.remove(key);

    return this;
  }

  /// Adds an attachment stored in the form of a [Blob] object.
  ///
  /// - Parameters:
  ///     - [blob]: Attachment data and unique name.
  MutableDocument addAttachment(Blob blob) {
    return addBlob(blob);
  }

  /// Adds a [Blob] to the document.
  ///
  /// - Parameters:
  ///     - [blob]: Attachment data and unique name.
  MutableDocument addBlob(Blob blob) {
    if (super.attachments == null) {
      super.attachments = Map();
    }

    if (blob.getUniqueName() == null ||
        blob.getUniqueName().isEmpty ||
        blob.getContentType() == null ||
        blob.getContentType().isEmpty ||
        blob.getData() == null) {
      throw CorruptBlobException();
    }

    super.attachments[blob.getUniqueName()] = {
      blob.getContentType(): blob.getData()
    };

    return this;
  }

  /// Returns the same MutableDocument object.
  ///
  /// - Returns: The MutableDocument object.
  @override
  MutableDocument toMutable() {
    return MutableDocument(this.internalState, this.id);
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
