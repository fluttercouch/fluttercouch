import 'package:flutter/material.dart';
import 'dart:async';

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

      db.addDocumentsChangeListener("first_id", (DocumentChange change) async {
        Document changedDocument = await change.getDatabase().getDocument(change.getDocumentID());
        print(changedDocument.getDate("newDate"));
        change = change;
      });

      Document doc = await db.getDocument("first_id");
      MutableDocument doc2 = doc.toMutable();
      doc2.setDate("newDate", DateTime.now());
      db.save(doc2);

      await db.setDocumentExpiration("first_id", DateTime.now().add(Duration(hours: 1)));
      DateTime expiration = await db.getDocumentExpiration("first_id");

      int docCount = await db.getCount();
      docCount = docCount;

      Replicator replicator;
      Uri uri = new Uri(scheme: "wss", host: "10.0.0.2", port: 4984, pathSegments: ["db"]);
      Endpoint endpoint = new URLEndpoint(uri);
      ReplicatorConfiguration config = new ReplicatorConfiguration(db, endpoint);

      config.setReplicatorType(ReplicatorType.PUSH_AND_PULL);
      replicator = new Replicator(config);
      replicator.start();
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
