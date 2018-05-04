import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> _docExample = {"name": "Prova"};

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, dynamic> docExample;
    String databaseName;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      databaseName = await Fluttercouch.initDatabaseWithName("infodiocesi");
      Fluttercouch.setReplicatorEndpoint("ws://:4984/infodiocesi");
      Fluttercouch.setReplicatorType("PUSH_AND_PULL");
      Fluttercouch.setReplicatorBasicAuthentication(<String,String>{
        "username": "defaultUser",
        "password": "defaultPassword"
      });
      Fluttercouch.startReplicator();
      docExample = await Fluttercouch.getDocumentWithId("diocesi_tab");
    } on PlatformException {
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _docExample = docExample;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('${_docExample['nome']}\n${_docExample['introText']}'),
        ),
      ),
    );
  }
}
