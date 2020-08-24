import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/listener_token.dart';

class Database {
  final String name;
  final DatabaseConfiguration _config = new DatabaseConfiguration();

  final Fluttercouch _fluttercouch = Fluttercouch();

  Database(this.name, {DatabaseConfiguration config}) {
    if (config != null) {
      this._config.setDirectory(config.getDirectory());
    }
    Future<Map<String, String>> result =
        _fluttercouch.initDatabaseWithName(name, configuration: _config);
    result.then((response) {
      this._config.setDirectory(response["directory"]);
      _fluttercouch.registerDatabase(this.name, this);
    });
  }

  /*ListenerToken addChangeListener(DatabaseChangeListener listener) {}

  ListenerToken addDocumentChangeListener(
      String id, DocumentChangeListener listener) {}
*/
  close() {
    _fluttercouch.closeDatabase.call(this.name);
  }

  compact() {
    _fluttercouch.compactDatabase.call(this.name);
  }

  //createIndex(String name, Index index) {}

  deleteDatabase() {
    _fluttercouch.deleteDatabase.call(this.name);
  }

  delete(Document document) {
    return _fluttercouch.deleteDocument(document.id, this.name);
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
    return _fluttercouch.getDocumentWithId(id, this.name);
  }

  Future<Null> setDocumentExpiration(String id, DateTime expiration) {
    return _fluttercouch.setDocumentExpirationOfDB(id, expiration,
        dbName: this.name);
  }

  Future<DateTime> getDocumentExpiration(String id) async {
    String date =
        await _fluttercouch.getDocumentExpirationOfDB(id, dbName: this.name);
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

  save(MutableDocument document,
      {ConcurrencyControl concurrencyControl,
      ConflictHandler conflictHandler}) {
    if (concurrencyControl != null && conflictHandler != null) {
      throw Exception(
          "You can specify either a concurrecy control method or a custom conflict handler, not both!");
    }
    if (document.id == null) {
      _fluttercouch.saveDocument(document, this.name);
    } else {
      _fluttercouch.saveDocumentWithId(document.id, document, this.name);
    }
  }

  ListenerToken addDocumentsChangeListener(
      String id, DocumentChangeListener listener) {
    ListenerToken token = new ListenerToken(
        _fluttercouch.registerDocumentChangeListener(listener));
    _fluttercouch.addDocumentChangeListener(id, token.tokenId,
        dbName: this.name);
    return token;
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
