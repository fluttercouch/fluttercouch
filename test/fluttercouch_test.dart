import 'package:fluttercouch/fluttercouch.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:fluttercouch/query/query_builder.dart';
import 'package:fluttercouch/query/select_result.dart';

void main() {
  const MethodChannel databaseChannel =
      MethodChannel('it.oltrenuovefrontiere.fluttercouch');
  const MethodChannel jsonChannel = MethodChannel(
      'it.oltrenuovefrontiere.fluttercouchJson', JSONMethodCodec());
  FluttercouchTest fluttercouch = FluttercouchTest.instance;

  setUp(() {
    databaseChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case ("initDatabaseWithName"):
          return methodCall.arguments;
          break;
        case ("closeDatabaseWithName"):
          return null;
          break;
        case ("deleteDatabaseWithName"):
          return null;
          break;
        case ("saveDocument"):
          return 'documentid';
          break;
        case ("saveDocumentWithId"):
          return methodCall.arguments["id"];
          break;
        case ("getDocumentWithId"):
          return {
            "id": methodCall.arguments["id"],
            "doc": {"testdoc": "test"}
          };

          break;
        case ("setReplicatorEndpoint"):
          return null;
          break;
        case ("setReplicatorType"):
          return null;
          break;
        case ("setReplicatorBasicAuthentication"):
          return null;
          break;
        case ("setReplicatorSessionAuthentication"):
          return null;
          break;
        case ("setReplicatorPinnedServerCertificate"):
          return null;
          break;
        case ("setReplicatorContinuous"):
          return null;
          break;
        case ("initReplicator"):
          return null;
          break;
        case ("startReplicator"):
          return null;
          break;
        case ("stopReplicator"):
          return null;
          break;
        case ("closeDatabase"):
          return "MyTestDatabase";
          break;
        case ("getDocumentCount"):
          return 1;
          break;
        default:
          return UnimplementedError();
      }
    });

    jsonChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "execute":
          return [];
          break;
        case "store":
          return true;
          break;
        case "remove":
          return true;
          break;
        default:
          return UnimplementedError();
          break;
      }
    });
  });

  tearDown(() {
    databaseChannel.setMethodCallHandler(null);
    jsonChannel.setMockMethodCallHandler(null);
  });

  test('testFluttercouch', () async {
    expect(await fluttercouch.initDatabaseWithName("MyTestDatabase"),
        "MyTestDatabase");
    expect(await fluttercouch.saveDocumentWithId("testid", Document({})),
        "testid");
    expect(await fluttercouch.saveDocument(Document({})), "documentid");
    await fluttercouch.initReplicator();
    await fluttercouch.setReplicatorBasicAuthentication(
        {"username": "test", "password": "12345678"});
    await fluttercouch.setReplicatorSessionAuthentication("sessionId");
    await fluttercouch.setReplicatorContinuous(true);
    await fluttercouch.setReplicatorEndpoint("endpoint");
    await fluttercouch.setReplicatorType("PUSH");
    await fluttercouch.startReplicator();
    await fluttercouch.stopReplicator();
    fluttercouch.deleteDatabaseWithName("MyTestDatabase");
  });

  test('testQuery', () async {
    Query query =
        QueryBuilder.select([SelectResult.all()]).from("test", as: "sheets");
    expect(await query.execute(), []);
  });
}

class FluttercouchTest with Fluttercouch {
  static final instance = FluttercouchTest._internal();

  FluttercouchTest._internal();
}
