import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercouch/fluttercouch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with Fluttercouch {
  String _isOK = 'Unable to initialize';

  @override
  void initState() {
    super.initState();
    initFluttercouchState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initFluttercouchState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    String result = "";
    
    try {
      String databaseName = await initDatabaseWithName("getting-started");
      MutableDocument mutableDoc = MutableDocument()
      .setDouble("version", 2.7)
      .setString("type", "SDK");

      saveDocumentWithId("first-document", mutableDoc);

      Document doc = await getDocumentWithId("first-document");
      result = "Initialized version " + doc.getDouble("version").toString();

      //platformVersion = await Fluttercouch.platformVersion;
    } on PlatformException {
      result = 'Failed initialization';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isOK = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_isOK\n'),
        ),
      ),
    );
  }
}
