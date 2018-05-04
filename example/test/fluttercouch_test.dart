import 'package:test/test.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() {
  test('initDatabaseWithName Database initialization', () async {
    var dbname = "mydb";
    var result = await Fluttercouch.initDatabaseWithName(dbname);
    expect(result, equals(dbname));
  });
}