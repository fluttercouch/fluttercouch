import 'package:fluttercouch/query/expression/meta_expression.dart';

class Meta {
  static MetaExpression get id => MetaExpression({"meta": "id"});
  static MetaExpression get sequence => MetaExpression({"meta": "sequence"});
}
