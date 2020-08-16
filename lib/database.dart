import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';

class Database extends Fluttercouch {
  String _name;
  DatabaseConfiguration _config;

  Database(String name, {DatabaseConfiguration config}) {
    this._name = name;
    this._config = config;
    initDatabaseWithName(_name);
  }

  ListenerToken addChangeListener(DatabaseChangeListener listener) {}

  ListenerToken addDocumentChangeListener(
      String id, DocumentChangeListener listener) {}

  close() {}

  compact() {}

  //createIndex(String name, Index index) {}

  deleteDatabase() {}

  delete(Document document)

  //bool delete(Document document, ConcurrencyControl concurrencyControl) {}

  //deleteIndex(String name) {}

  DatabaseConfiguration getConfig() {
    return this._config;
  }

  double getCount() {}

  Document getDocument(String id) {}

  DateTime getDocumentExpiration(String id) {}

  //List<String> getIndexes() {}

  String getName() {}

  String getPath() {}

  purge(Document document) {

  }

  //purge(String id) {}

  removeChangeListener(ListenerToken token) {}

  save(MutableDocument document) {}

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

abstract class DatabaseChangeListener {
  changed(DatabaseChange change);
}

abstract class DocumentChangeListener {
  changed(DocumentChange change);
}

abstract class ListenerToken {

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
