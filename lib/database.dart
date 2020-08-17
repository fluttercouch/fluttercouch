import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/listener_token.dart';

class Database extends Fluttercouch {
  String _name;
  DatabaseConfiguration _config;
  bool _initialized = false;

  Stream _eventsStream = Fluttercouch.eventChannel.receiveBroadcastStream();
  Map<ListenerToken, Function> _documentsChangeListeners = new Map();

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

  _onEvent(Object event) {
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

  DateTime getDocumentExpiration(String id) {}

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
    registerDocumentChangeListener(id, token.tokenId, dbName: this.getName()).then((resultToken) {
      _documentsChangeListeners[token] = listener;
    });
  }

  //save(MutableDocument document, ConcurrencyControl concurrencyControl) {}

  //save(MutableDocument document, ConflictHandler conflictHandler) {}

  setDocumentExpiration(String id, DateTime expiration) {}

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
