# Fluttercouch
With Fluttercouch is possible to use Couchbase Mobile Native SDK in Flutter Projects.

The plugin takes advantage of Flutter ability to write platform specific code to instantiate and manage a Couchbase Lite database. The Fluttercouch library is a wrapper to native SDK, which is handled from Dart through “mockup” objects. Those objects are responsible for creating local database, making CRUD operation and interact with a Couchbase database through platform channels.

None of the Dart object holds the actual state (which is hold in the native code). They are an interface to operate the native SDK in an easy and workable manner, helping developers to not deal with native layer directly.

## Installation

In order to use Fluttercouch, add this code to pubspec.yaml in your project directory. (Thanks to DhudumVishal)
```  fluttercouch: 
    git: 
      url: git://github.com/oltrenuovefrontiere/fluttercouch.git
```
The standard installation mode through pub.dartlang.org will be available in further releases.

NOTES:
- The current version uses the Couchbase Lite SDK 2.1 for Android and iOs.
- Due to Couchbase Lite SDK restrictions, the minSdkVersion for Android is 19 (Android KitKat 4.4) and minimum platform for iOs is 9.0

## Code Reference

### Initialization
The package is designed as a mix-in for a model class. After importing the main file in your code and extending a class with Fluttercouch mix-in, you can use the package. Remember that you can use the same code for Android and iOs development because Fluttercouch handles automatically the native code for the two different platforms for you.
```dart
import ‘package:fluttercouch/fluttercouch.dart’;

class MyModel extends Object with Fluttercouch {
}
```
Define an async method to initialize a Couchbase Lite database and wrap the initialization code within a try / catch block to watch for PlatformException error. The initDatabaseWithName() method returns a string with the name of the database, but saving its result is optional. Infact Fluttercouch consider the last initialized database as the default database, and further commands refers to that database. Unfortunately, handling multiple databases is not fully supported at the moment.
```dart
initFluttercouch() async {
  try {
  await initDatabaseWithName(‘myDatabaseName’);
  } on PlatformException {
    // Handle error during database initialization
  }
}
```
If the database already exists in a device, nothing is done (except for changing default database reference). Hence you can safely init a database many times in different sections of your code or among various launch of your application.
The database is now available in any part of your class mixed with Fluttercouch.

### Replication Configuration
You can configure a replicator with the following methods:
```dart
// Supplies the address of the database replicated by the Sync Gateway server. 
// In case you want to enable SSL encryption, use wss:// insted of ws://. 
// To connect to a local Sync Gateway instance, use localhost as hostname for iOs simulator, and 10.0.2.2 for Android simulator.
setReplicatorEndpoint("ws://your-server-address:4984/yourReplicationDatabaseName");

// Sets the replication type as PULL, PUSH or PUSH_AND_PULL
setReplicatorType("PUSH_AND_PULL");

// Sets the replication as continuous
setReplicatorContinuous(true);

// Sets a BasicAuthenticator for the replication. The methods accept a parameter of type Map<String, String> 
// with two keys named "username" and "password".
setReplicatorBasicAuthentication(<String, String>{
  "username": "yourUsername",
  "password": "yourPassword"
});

// Sets a SessionAuthenticator for the replication. SessionID is retrieved querying the public REST API of your Sync Gateway
setReplicatorSessionAuthentication(sessionID);

// Before starting the replication, you must init the replicator object
initReplicator();

// Starts the replication
startReplicator();

// Stops the replication
stopReplicator();
```

You can listen for replication events passing a function to the listenReplicatorEvents method. The listenReplicatorEvents calls the function with a parameter containing the event type.
```dart
listenReplicationEvents((dynamic event) {
    switch(event) {
      case ("BUSY"):
        // executed when the replicator status changes to BUSY
      case ("IDLE"):
        // executed when the replicator status changes to IDLE
      case ("OFFLINE"):
        // executed when the replicator status changes to OFFLINE
      case ("STOPPED"):
        // executed when the replicator status changes to STOPPED
      case ("CONNECTING"):
        // executed when the replicator status changes to CONNECTING
    }
  }
);
```

### Basic CRUD operations
As in Couchbase Lite native implementations, documents are managed through Document and MutableDocument objects.
To retrieve a document by ID, you wait for the the result of the getDocumentWithId method.
```dart
Document document = await getDocumentWithId("document::ID");
```
To save a document to the database, you can use any of the following methods. Because MutableDocument is a subclass of Document, you can pass either types to saveDocument().
```dart
saveDocument(document);
saveDocumentWithId("aDocument::ID", document);
```
Document and MutableDocument object expose getter methods to get values for a key.
```dart
// retrieves the value related to the "key" as Boolean
aBoolean = document.getBoolean("key");
// retrieves the value related to the "key" as Double
aDouble = document.getDouble("key");
// retrieves the value related to the "key" as Int
aInt = document.getInt("key");
// retrieves the value related to the "key" as String
aString = document.getString("key");
// retrieves the value related to the "key" as List of type T
aList = document.getList<T>("key");
// retrieves the value related to the "key" as Map of type K, V
aMap = document.getMap<K, V>("key");
```
Document and MutableDocument have also methods that help to handle various aspect of documents.
```dart
const document = new Document(); // initializes a new empty document
document.contains("key");        // returns true if the document contains the specified key
document.count();                // returns the number of first level field in the document
document.getKeys();              // returns a List<String> that contains the first level keys of the document
document.toMap();                // returns the document as a Map<String, dynamic>
document.toMutable();            // returns a mutable copy of the document as MutableDocument
document.getId();                // returns the id of the document. If not supplied, the id is setted after having saved the document in the database
document.isNotEmpty();           // returns true if the document has at least one key/value pairs
document.isNotNull();            // returns true if the document is correctly initialized
document.isEmpty();              // returns true if the document doesn't have any key/value pairs
```
Because SubDocument operations are not currently supported, Fluttercouch supply a convenience method to get a List of Map that handles the conversion from dynamic type automatically. The method returns a List of type Map<K, V> (List<Map<K,V>>)
```dart
List<Map<K,V>> aListOfMap = document.getListOfMap<K, V>("key");
```
The MutableDocument class exposes setter methods to set document key/value pairs
```dart
// initializes a new empty mutable document
const mutableDocument = new MutableDocument();
// you can optionally specify an id or a map to initialize the key/value pairs
const mutableDocument = new MutableDocument(id: "anID", map: {"key": "value"});

mutableDocument.setArray("key", aList<AnyType>);  // set a List as the value of "key"
mutableDocument.setBoolean("key", false);         // set a Boolean as the value of "key"
mutableDocument.setDouble("key", aDouble);        // set a Double as the value of "key"
mutableDocument.setInt("key", aInt>);             // set a Int as the value of "key"
mutableDocument.setString("key", "aString");      // set a String as the value of "key"
mutableDocument.remove("key");                    // remove the key/value pairs from the document
```

## Roadmap
The first goal is to implement all software parts needed to run the starter code listed <a href="https://developer.couchbase.com/documentation/mobile/2.0/couchbase-lite/java.html">here</a> in Flutter.

The aim is to construct a “zero-documentation” plugin that can be used by following the Couchbase Mobile Documentation for other platforms. Therefore, any adaptation to the Flutter style has to be optional although strongly desirable, such as integration with Inherited Widgets or other Flutter plugins that manage data and model layers.

The Fluttercouch plugin is still under development and any contribution is welcome.

## Current development

By now, the library can create (in Android device and iOs devices) a database locally and replicate a couchbase server by connecting to a sync gateway. It can retrieve a Document by id and extract any “usual” field (no blob) and save it back to the Database.
Queries are still missing, but are under development.
The iOs native code will be implemented after Android implementation is confirmed as a good approach for queries too, so that middleware code would not be written twice.

Any suggestion or feedback is appreciated.