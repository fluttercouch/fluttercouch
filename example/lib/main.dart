import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/blob.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/mutable_document.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppModel extends Model with Fluttercouch {
  String _databaseName;
  Document docExample;
  Query query;

  AppModel() {
    initPlatformState();
  }

  initPlatformState() async {
    try {
      _getSampleBlob(String attachmentName) async {
        var attachmentContentType = "image/png";
        var attachmentData = await rootBundle.load("assets/images/cb_logo.png");
        var bytes = attachmentData.buffer.asUint8List(
            attachmentData.offsetInBytes, attachmentData.lengthInBytes);

        return Blob(attachmentName, attachmentContentType, bytes);
      }

      _databaseName = await initDatabaseWithName("infodiocesi");
      setReplicatorEndpoint("ws://localhost:4984/infodiocesi");
      setReplicatorType("PUSH_AND_PULL");
      setReplicatorBasicAuthentication(<String, String>{
        "username": "defaultUser",
        "password": "defaultPassword"
      });
      setReplicatorContinuous(true);
      initReplicator();
      startReplicator();
      docExample = await getDocumentWithId("diocesi_tab");
      notifyListeners();

      MutableDocument mutableDoc = MutableDocument();
      mutableDoc.setString("prova", "");
      String blobName = "cbLogo";
      mutableDoc.addBlob(await _getSampleBlob(blobName));
      String docId = await saveDocument(mutableDoc);
      Blob blobData = await getBlob(docId, blobName);
      print("blobData: $blobData");

    } on PlatformException {
      print("Platform Exception: Failed to perform cb operations.");
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
              builder: (context, child, model) => new Text(
                'Ciao',
                style: Theme.of(context).textTheme.display1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
