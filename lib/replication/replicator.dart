import 'package:uuid/uuid.dart';

import '../fluttercouch.dart';
import '../listener_token.dart';
import 'document_replication.dart';
import 'replicator_change.dart';
import 'replicator_configuration.dart';

typedef ReplicatorChangeListener = void Function(ReplicatorChange change);
typedef DocumentReplicationListener = void Function(
    DocumentReplication replication);

class Replicator {
  final ReplicatorConfiguration config;
  final String _uuid = new Uuid().v1();
  final _fluttercouch = Fluttercouch();

  Replicator([this.config]) {
    _fluttercouch.initReplicator().then((response) {
      _fluttercouch.registerReplicator(_uuid, this);
    });
  }

  ReplicatorConfiguration getConfig() => config;

  ListenerToken addChangeListener(
      ReplicatorChangeListener replicatorChangeListener) {
    ListenerToken listenerToken = new ListenerToken(_fluttercouch
        .registerReplicatorChangeListener(replicatorChangeListener));
    _fluttercouch.addReplicatorChangeListener(
        this._uuid, listenerToken.tokenId);
    return listenerToken;
  }

  ListenerToken addDocumentReplicationListener(
      DocumentReplicationListener documentReplicationListener) {
    ListenerToken listenerToken = new ListenerToken(_fluttercouch
        .registerDocumentReplicationListener(documentReplicationListener));
    _fluttercouch.addDocumentReplicationListener(
        this._uuid, listenerToken.tokenId);
    return listenerToken;
  }

  void removeChangeListener(ListenerToken token) {
    _fluttercouch.unregisterReplicatorChangeListener(token.tokenId);
    _fluttercouch.removeReplicatorChangeListener(this._uuid, token.tokenId);
  }

  void resetCheckpoint() {}

  void start() {}

  void stop() {}
}
