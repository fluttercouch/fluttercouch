class Parameters {
  Map<String, dynamic> map;

  dynamic getValue(String name) {
    if (map.containsKey(name)) {
      return map[name];
    } else {
      return null;
    }
  }

  Parameters setBoolean(String name, bool value) {
    map[name] = value;
    return this;
  }

  Parameters setDate(String name, DateTime value) {
    map[name] = value;
    return this;
  }

  Parameters setDouble(String name, double value) {
    map[name] = value;
    return this;
  }

  Parameters setInt(String name, int value) {
    map[name] = value;
    return this;
  }

  Parameters setString(String name, String value) {
    map[name] = value;
    return this;
  }

  Parameters setValue(String name, dynamic value) {
    map[name] = value;
    return this;
  }
}
