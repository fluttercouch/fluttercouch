import 'replicator.dart';
import 'status.dart';

class ReplicatorChange {
  final Replicator replicator;
  final Status status;

  ReplicatorChange(this.replicator, this.status);

  Replicator getReplicator() => replicator;
  Status getStatus() => status;
}