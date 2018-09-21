import 'package:fluttercouch/document.dart';

class MutableDocument extends Document {
  Map<String, dynamic> _internalState;
  String _id;

  MutableDocument([Map<dynamic, dynamic> _map, String _id]) {
    if (_map != null) {
      _internalState = super.stringMapFromDynamic(_map);
    } else {
      _internalState = Map<String, dynamic>();
    }

    _id != null ? this._id = _id : _id = "random UUID";
  }

  setValue(String key, Object value) {
    if (value != null) {
      _internalState[key] = value;
    }
  }

  setArray(String key, List<Object> value) {
    setValue(key, value);
  }

  setBoolean(String key, bool value) {
    setValue(key, value);
  }

  setDouble(String key, double value) {
    setValue(key, value);
  }

  setInt(String key, int value) {
    setValue(key, value);
  }

  setString(String key, String value) {
    setValue(key, value);
  }

  remove(String key) {
    _internalState.remove(key);
  }
}
