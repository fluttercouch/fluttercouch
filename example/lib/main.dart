import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _databaseName = 'Null';
  String _docId;
  Map<String, dynamic> _docExample = {"name": "Prova"};

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    String databaseName;
    String docId;
    Map<String, dynamic> docExample;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Fluttercouch.platformVersion;
      databaseName = await Fluttercouch.initDatabaseWithName("mydb");
      docId = await Fluttercouch.saveDocument(<String, dynamic> {
        "name": "Luca",
        "age": 12
      });
      docExample = await Fluttercouch.getDocumentWithId(docId);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
      _databaseName = databaseName;
      _docId = docId;
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
          child: new Text('Retrieving document $_docId with name: ${_docExample['name']}\n'),
        ),
      ),
    );
  }
}
