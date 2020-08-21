import 'package:uuid/uuid.dart';

import '../fluttercouch.dart';
import '../listener_token.dart';
import 'authenticator.dart';
import 'document_replication.dart';
import 'endpoint.dart';
import 'replicator_change.dart';
import 'replicator_configuration.dart';

typedef ReplicatorChangeListener = void Function(ReplicatorChange change);
typedef DocumentReplicationListener = void Function(DocumentReplication replication);

class Replicator {
  final ReplicatorConfiguration config;
  final Map<String, ReplicatorChangeListener> _replicatorChangeListeners = new Map();
  final Map<String, DocumentReplicationListener> _documentReplicationListeners = new Map();
  final String _uuid = new Uuid().v1();
  final _fluttercouch = new _Fluttercouch();

  Replicator([this.config]) {
    _fluttercouch.initReplicator().then((response) {
      Fluttercouch.registerReplicator(_uuid, this);
    });
  }

  ReplicatorConfiguration getConfig() => config;

  Authenticator getAuthenticator() => config.getAuthenticator();

  List<String> getChannels() => config.getChannels();

  ConflictResolver getConflictResolver() => config.getConflictResolver();

  List<String> getDocumentIDs() => config.getDocumentIDs();

  Map<String, String> getHeaders() => config.getHeaders();

  // byte[] getPinnedCertificate()

  ReplicationFilter getPullFilter() => config.getPullFilter();

  ReplicationFilter getPushFilter() => config.getPushFilter();

  ReplicatorType getReplicatorType() => config.getReplicatorType();

  Endpoint getTarget() => config.getTarget();

  bool isContinuous() => config.isContinuous();

  ReplicatorConfiguration setAuthenticator(Authenticator authenticator) {
    config.setAuthenticator(authenticator);
    return config;
  }

  ReplicatorConfiguration setChannels(List<String> channels) {
    config.setChannels(channels);
    return config;
  }

  ReplicatorConfiguration setConflictResolver(ConflictResolver conflictResolver) {
    config.setConflictResolver(conflictResolver);
    return config;
  }

  ReplicatorConfiguration setContinuous(bool continuous) {
    config.setContinuous(continuous);
    return config;
  }

  ReplicatorConfiguration setDocumentIDs(List<String> documentsIDs) {
    config.setDocumentIDs(documentsIDs);
    return config;
  }

  ReplicatorConfiguration setHeaders(Map<String, String> headers) {
    config.setHeaders(headers);
    return config;
  }

  /*ReplicatorConfiguration setPinnedServerCertificate(String pinnedServerCertificate) {
    return _config;
  }*/

  ReplicatorConfiguration setPullFilter(ReplicationFilter pullFilter) {
    config.setPullFilter(pullFilter);
    return config;
  }

  ReplicatorConfiguration setPushFilter(ReplicationFilter pushFilter) {
    config.setPushFilter(pushFilter);
    return config;
  }

  ReplicatorConfiguration setReplicatorType(ReplicatorType replicatorType) {
    config.setReplicatorType(replicatorType);
    return config;
  }

  void removeChangeListener(ListenerToken token) {
    if (_replicatorChangeListeners.containsKey(token.tokenId)) {
      _replicatorChangeListeners.remove(token.tokenId);
    }
    if (_documentReplicationListeners.containsKey(token.tokenId)) {
      _replicatorChangeListeners.remove(token.tokenId);
    }
  }

  void resetCheckpoint() {}

  void start() {}

  void stop() {}
}

class _Fluttercouch extends Fluttercouch {}

