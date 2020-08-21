import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/listener_token.dart';

class Database {
  final String name;
  final DatabaseConfiguration _config = new DatabaseConfiguration();
  bool _initialized = false;
  _Fluttercouch _fluttercouch = new _Fluttercouch();

  final Stream _eventsStream = Fluttercouch.eventChannel.receiveBroadcastStream();
  final Map<String, Function> _documentsChangeListeners = new Map();

  Database(this.name, {DatabaseConfiguration config}) {
    if (config != null) {
    this._config.setDirectory(config.getDirectory());
    }
    Future<Map<String, String>> result =
        _fluttercouch.initDatabaseWithName(name, configuration: _config);
    result.then((response) {
      this._config.setDirectory(response["directory"]);
      this._initialized = true;
      Fluttercouch.registerDatabase(this.name, this);
    });
    _eventsStream.listen(_onEvent, onError: _onEventError);
    Fluttercouch.initMethodCallHandler();
  }

  _onEvent(dynamic data) {
    Map<String, String> event = Map.castFrom<dynamic, dynamic, String, String>(data);
    if (event.containsKey("type")) {
      switch(event["type"]) {
        case "document_change_event":
          DocumentChange change = DocumentChange();
          change._database = Fluttercouch.getRegisteredDatabase(event["database"]);
          change._documentID = event["documentID"];
          DocumentChangeListener documentChangeListener = this._documentsChangeListeners[event["listenerToken"]];
          if (documentChangeListener != null) {
            documentChangeListener(change);
          }
          break;
      }
    }
    event = event;
  }

  _onEventError(Object error) {

  }

  /*ListenerToken addChangeListener(DatabaseChangeListener listener) {}

  ListenerToken addDocumentChangeListener(
      String id, DocumentChangeListener listener) {}
*/
  close() {
    _fluttercouch.closeDatabaseWithName.call(this.name);
  }

  compact() {
    _fluttercouch.compactDatabaseWithName.call(this.name);
  }

  //createIndex(String name, Index index) {}

  deleteDatabase() {
    _fluttercouch.deleteDatabaseWithName.call(this.name);
  }

  delete(Document document) {
    return _fluttercouch.deleteDocument(document.id, dbName: this.name);
  }

  //bool delete(Document document, ConcurrencyControl concurrencyControl) {}

  //deleteIndex(String name) {}

  DatabaseConfiguration getConfig() {
    return this._config;
  }

  Future<int> getCount() async {
    return _fluttercouch.getDocumentCount(dbName: this.name);
  }

  Future<Document> getDocument(String id) {
    return _fluttercouch.getDocumentWithId(id, dbName: this.name);
  }

  Future<Null> setDocumentExpiration(String id, DateTime expiration) {
    return _fluttercouch.setDocumentExpirationOfDB(id, expiration, dbName: this.name);
  }

  Future<DateTime> getDocumentExpiration(String id) async {
    String date = await _fluttercouch.getDocumentExpirationOfDB(id, dbName: this.name);
    return DateTime.parse(date);
  }

  //List<String> getIndexes() {}

  String getName() {
    return this.name;
  }

  String getPath() {
    return this._config.getDirectory();
  }

  purge(Document document) {}

  //purge(String id) {}

  removeChangeListener(ListenerToken token) {}

  save(MutableDocument document, {ConcurrencyControl concurrencyControl, ConflictHandler conflictHandler}) {
    if (concurrencyControl != null && conflictHandler != null) {
      throw Exception("You can specify either a concurrecy control method or a custom conflict handler, not both!");
    }
    if (document.id == null) {
      _fluttercouch.saveDocument(document);
    } else {
      _fluttercouch.saveDocumentWithId(document.id, document);
    }
  }

  addDocumentsChangeListener(String id, DocumentChangeListener listener) {
    ListenerToken token = new ListenerToken.v5(this.name + "::" + "document_change_listener", id);
    _documentsChangeListeners[token.tokenId] = listener;
    _fluttercouch.registerDocumentChangeListener(id, token.tokenId, dbName: this.getName());
  }

  //save(MutableDocument document, ConcurrencyControl concurrencyControl) {}

  //save(MutableDocument document, ConflictHandler conflictHandler) {}

  static copy(String path, String name, DatabaseConfiguration config) {}

  static deleteDatabaseWith(String name, String directory) {}

  static exists(String name, String directory) {}
}

class DatabaseConfiguration {
  String _directory;

  // Encryption Key is not currently supported

  /*
   * Set the path to the directory to store the database in.
   * If the directory doesn't already exist it will be created when the database is opened.
   */
  DatabaseConfiguration setDirectory(String directory) {
    this._directory = directory;
    return this;
  }

  /*
   * Returns the path to the directory to store the database in.
   */
  String getDirectory() {
    return this._directory;
  }
}

class DatabaseChange {
  Database _database;
  List<String> _documentIDs;

  Database getDatabase() {
    return this._database;
  }

  List<String> getDocumentIDs() {
    return this._documentIDs;
  }
}

class DocumentChange {
  Database _database;
  String _documentID;

  Database getDatabase() {
    return this._database;
  }

  String getDocumentID() {
    return this._documentID;
  }
}

enum ConcurrencyControl {
  FAIL_ON_CONFLICT, LAST_WRITE_WINS
}

class _Fluttercouch extends Fluttercouch {}
