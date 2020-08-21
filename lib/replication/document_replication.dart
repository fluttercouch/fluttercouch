import '../couchbase_lite_exception.dart';
import 'replicator_configuration.dart';

class DocumentReplication {
  final Set<DocumentFlag> flags;
  final CouchbaseLiteException exception;
  final String id;

  DocumentReplication(this.flags, this.exception, this.id);

  Set<DocumentFlag> getFlags() => flags;
  CouchbaseLiteException getError() => exception;
  String getID() => id;
}