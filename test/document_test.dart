import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() {
  Map initializer;
  Document document;
  MutableDocument mutableDocument;
  setUp(() {
    initializer = new Map();
    initializer['string'] = "string";
    initializer['double'] = 3.14;
    initializer['int'] = 12;
    initializer['map'] = {};
    initializer['boolInt'] = 0;
    initializer['bool'] = true;
    initializer['list'] = [];
    document = Document(initializer, "123456789");
    mutableDocument = MutableDocument();
  });

  test("Document: getting string", () {
    expect(document.count(), initializer.length);
  });
  test("Document: getting string", () {
    expect(document.getString('string'), "string");
  });
  test("Document: getting double", () {
    expect(document.getDouble('double'), 3.14);
  });
  test("Document: getting int", () {
    expect(document.getInt('int'), 12);
  });
  test("Document: getting double int", () {
    expect(document.getDouble('int'), 12);
  });
  test("Document: getting map", () {
    expect(document.getMap('map'), {});
  });
  test("Document: getting list", () {
    expect(document.getList('list'), []);
  });
  test("Document: to map", () {
    expect(document.toMap(), initializer);
  });
  test("Document: getting bool", () {
    expect(document.getBoolean("bool"), true);
  });
  test("Document: getting bool int", () {
    expect(document.getBoolean("boolInt"), false);
  });
  test("Document: null list", () {
    expect(document.getMap("null"), null);
  });
  test("Document: null map", () {
    expect(document.getList("null"), null);
  });
  test("Document: invalid list", () {
    expect(document.getMap("boolInt"), null);
  });
  test("Document: invalid map", () {
    expect(document.getList("boolInt"), null);
  });
  test("Document: getting getKeys", () {
    expect(document.getKeys(), initializer.keys);
  });
  test("Document: getting id", () {
    expect(document.id, "123456789");
  });
  test("mutableDocument: setting string", () {
    mutableDocument.setString('string', 'string');
    expect(mutableDocument.getString('string'), "string");
  });
  test("mutableDocument: setting double", () {
    mutableDocument.setDouble('double', 3.14);
    expect(mutableDocument.getDouble('double'), 3.14);
  });
  test("mutableDocument: setting int", () {
    mutableDocument.setInt('int', 12);
    expect(mutableDocument.getInt('int'), 12);
  });
  test("mutableDocument: setting id", () {
    mutableDocument.id = "123456789";
    expect(mutableDocument.id, "123456789");
    expect(mutableDocument.toMutable().id, "123456789");
  });
  test("mutableDocument: setting map", () {
    mutableDocument.setMap('map', <String, dynamic>{"test": true});
    expect(mutableDocument.getMap('map'), {"test": true});
  });
  test("mutableDocument: setting list", () {
    mutableDocument.setArray('list', List<int>());
    expect(mutableDocument.getList('list'), []);
  });
  test("mutableDocument: null list", () {
    expect(mutableDocument.getMap("null"), null);
  });
  test("mutableDocument: null map", () {
    expect(mutableDocument.getList("null"), null);
  });
  test("mutableDocument: invalid list", () {
    expect(mutableDocument.getMap("boolInt"), null);
  });
  test("mutableDocument: invalid map", () {
    expect(mutableDocument.getList("boolInt"), null);
  });
  test("mutableDocument: to map", () {
    mutableDocument.setBoolean("bool", true);
    mutableDocument.setInt('int', 12);
    mutableDocument.remove('int');
    expect(mutableDocument.toMap(), {"bool": true});
  });
  test("mutableDocument: getting bool", () {
    mutableDocument.setBoolean("bool", true);
    expect(document.getBoolean("bool"), true);
  });
  test("NullDocument", () {
    expect(Document(null, "test").toMap(), {});
  });
}
