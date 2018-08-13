import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/mutable_document.dart';
import 'package:fluttercouch/query/expression/expression.dart';
import 'package:fluttercouch/query/expression/meta.dart';
import 'package:fluttercouch/query/ordering.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:fluttercouch/query/query_builder.dart';
import 'package:fluttercouch/query/select_result.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model with Fluttercouch {
  String _databaseName;
  Document docExample;
  Query query;

  AppModel() {
    initPlatformState();
  }

  initPlatformState() async {
    try {
      _databaseName = await initDatabaseWithName("infodiocesi");
      setReplicatorEndpoint("ws://10.0.2.2:4984/infodiocesi");
      setReplicatorType("PUSH_AND_PULL");
      setReplicatorBasicAuthentication(<String, String>{
        "username": "defaultUser",
        "password": "defaultPassword"
      });
      startReplicator();
      docExample = await getDocumentWithId("diocesi_tab");
      notifyListeners();
      MutableDocument mutableDoc = MutableDocument();
      mutableDoc.setString("prova", "");
      Query query = QueryBuilder
          .select(
          [SelectResult.expression(Meta.id), SelectResult.property("name")])
          .from("database")
          .where(
          Expression.property("type").equalTo(Expression.string("hotel")))
          .orderBy(
          [Ordering.property("name").ascending(), Ordering.expression(Meta.id)])
          .limit(Expression.intValue(10));
      query.execute();
    } on PlatformException {}
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Fluttercouch example application',
        home: new ScopedModel<AppModel>(
          model: new AppModel(),
          child: new Home(),
        ));
  }
}

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Fluttercouch example application'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Text("This is an example app"),
            new ScopedModelDescendant<AppModel>(
              builder: (context, child, model) =>
              new Text(
                'Ciao',
                style: Theme
                    .of(context)
                    .textTheme
                    .display1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
