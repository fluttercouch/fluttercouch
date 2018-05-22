import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model with Fluttercouch {
  String _databaseName;
  Map<dynamic, dynamic> docExample = {"nome": "Prova"};

  AppModel() {
    initPlatformState();
  }

  initPlatformState() async {
    try {
      _databaseName = await initDatabaseWithName("infodiocesi");
      setReplicatorEndpoint("ws://10.0.2.2:4984/infodiocesi");
      setReplicatorType("PUSH_AND_PULL");
      setReplicatorBasicAuthentication(<String,String>{
        "username": "defaultUser",
        "password": "defaultPassword"
      });
      startReplicator();
      docExample = await getDocumentWithId("diocesi_tab");
      notifyListeners();
    } on PlatformException {
    }

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

      )
    );
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
            builder: (context, child, model) => new Text(
              '${model.docExample['nome']}\n${model.docExample['introText']}',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
