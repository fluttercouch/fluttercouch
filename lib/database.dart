import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/listener_token.dart';

class Database extends Fluttercouch {
  String _name;
  DatabaseConfiguration _config;
  bool _initialized = false;

  Stream _eventsStream = Fluttercouch.eventChannel.receiveBroadcastStream();
  Map<String, Function> _documentsChangeListeners = new Map();

  Database(String name, {DatabaseConfiguration config}) {
    this._name = name;
    this._config = config;
    Future<Map<String, String>> result =
        initDatabaseWithName(_name, configuration: _config);
    result.then((response) {
      this._name = response["dbName"];
      this._config.setDirectory(response["directory"]);
      this._initialized = true;
      Fluttercouch.registerDatabase(this._name, this);
    });
    _eventsStream.listen(_onEvent, onError: _onEventError);
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
    closeDatabaseWithName.call(this._name);
  }

  compact() {
    compactDatabaseWithName.call(this._name);
  }

  //createIndex(String name, Index index) {}

  deleteDatabase() {
    deleteDatabaseWithName.call(this._name);
  }

  delete(Document document) {
    return deleteDocument(document.id, dbName: this._name);
  }

  //bool delete(Document document, ConcurrencyControl concurrencyControl) {}

  //deleteIndex(String name) {}

  DatabaseConfiguration getConfig() {
    return this._config;
  }

  Future<int> getCount() async {
    return getDocumentCount(dbName: this._name);
  }

  Future<Document> getDocument(String id) {
    return getDocumentWithId(id, dbName: this._name);
  }

  Future<Null> setDocumentExpiration(String id, DateTime expiration) {
    return setDocumentExpirationOfDB(id, expiration, dbName: this._name);
  }

  Future<DateTime> getDocumentExpiration(String id) async {
    String date = await getDocumentExpirationOfDB(id, dbName: this._name);
    return DateTime.parse(date);
  }

  //List<String> getIndexes() {}

  String getName() {
    return this._name;
  }

  String getPath() {
    return this._config.getDirectory();
  }

  purge(Document document) {}

  //purge(String id) {}

  removeChangeListener(ListenerToken token) {}

  save(MutableDocument document) {
    if (document.id == null) {
      saveDocument(document);
    } else {
      saveDocumentWithId(document.id, document);
    }
  }

  addDocumentsChangeListener(String id, DocumentChangeListener listener) {
    ListenerToken token = new ListenerToken.v5(this._name + "::" + "document_change_listener", id);
    _documentsChangeListeners[token.tokenId] = listener;
    registerDocumentChangeListener(id, token.tokenId, dbName: this.getName());
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
