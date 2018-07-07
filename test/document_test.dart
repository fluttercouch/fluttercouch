import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/document.dart';

void main() {
  Document document;
  setUp(() {
    var initializer = new Map();
    initializer['string'] = "string";
    initializer['double'] = 3.14;
    initializer['int'] = 12;
    document = Document(initializer, "123456789");
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
  test("Document: getting id", () {
    expect(document.getId(), "123456789");
  });
}
