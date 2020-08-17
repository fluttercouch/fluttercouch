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

class _MyAppState extends State<MyApp> {
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
      DatabaseConfiguration dbConfig = DatabaseConfiguration();
      Database db = new Database("getting-started", config: dbConfig);
      Query query = QueryBuilder.select([SelectResult.expression(Meta.id)])
          .from(db.getName());
      ResultSet resultSet = await query.execute();
      for (Result result in resultSet) {
        String id = result.getString(index: 0);

        Document document = await db.getDocument(id);
        if (document != null) {
          db.delete(document);
        }
      }

      MutableDocument mutableDoc = MutableDocument(withID: "first_id")
          .setDouble("version", 2.7)
          .setString("type", "SDK")
          .setDate("date", DateTime.now());

      db.save(mutableDoc);

      db.addDocumentsChangeListener("first_id", (change) {
        change = change;
      });

      Document doc = await db.getDocument("first_id");
      MutableDocument doc2 = doc.toMutable();
      doc2.setDate("newDate", DateTime.now());
      db.save(doc2);

      int docCount = await db.getCount();
      docCount = docCount;
    } catch (e) {
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
