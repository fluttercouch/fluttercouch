import '../couchbase_lite_exception.dart';

class Status {
  final ActivityLevel activityLevel;
  final CouchbaseLiteException couchbaseLiteException;
  final Progress progress;

  Status(this.activityLevel, this.couchbaseLiteException, this.progress);
}

enum ActivityLevel {
  STOPPED,
  OFFLINE,
  CONNECTING,
  IDLE,
  BUSY
}

class Progress {
  final int completed;
  final int total;

  Progress(this.completed, this.total);
}