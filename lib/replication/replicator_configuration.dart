import 'package:uuid/uuid.dart';

import '../database.dart';
import '../document.dart';
import '../fluttercouch.dart';
import 'authenticator.dart';
import 'conflict.dart';
import 'endpoint.dart';

typedef ConflictResolver = Document Function(Conflict conflict);
typedef ReplicationFilter = bool Function(Document document, Set<DocumentFlag> flags);

class ReplicatorConfiguration {
  Authenticator _authenticator;
  List<String> _channels;
  List<String> _documentIDs;
  Map<String, String> _headers;
  ConflictResolver _conflictResolver;
  ReplicationFilter _pullFilter;
  ReplicationFilter _pushFilter;
  ReplicatorType _replicatorType;

  final Endpoint target;
  bool _continuous;
  final Database database;
  String _uuid = new Uuid().v1();
  final _fluttercouch = new _Fluttercouch();

  final Stream _eventsStream = Fluttercouch.eventChannel.receiveBroadcastStream();

  ReplicatorConfiguration(this.database, this.target) {
    _fluttercouch.constructReplicatorConfiguration(_uuid, database, target);
  }
  
  factory ReplicatorConfiguration.from(ReplicatorConfiguration replicatorConfiguration) {
    ReplicatorConfiguration result = ReplicatorConfiguration(replicatorConfiguration.getDatabase(), replicatorConfiguration.getTarget());
    result.setAuthenticator(replicatorConfiguration.getAuthenticator());
    result.setChannels(replicatorConfiguration.getChannels());
    result.setDocumentIDs(replicatorConfiguration.getDocumentIDs());
    result.setHeaders(replicatorConfiguration.getHeaders());
    result.setConflictResolver(replicatorConfiguration.getConflictResolver());
    result.setPullFilter(replicatorConfiguration.getPullFilter());
    result.setPushFilter(replicatorConfiguration.getPushFilter());
    result.setReplicatorType(replicatorConfiguration.getReplicatorType());
    result.setContinuous(replicatorConfiguration.isContinuous());
    return result;
  }

  _onEvent(Object data) {

  }

  _onEventError(Object data) {

  }

  Authenticator getAuthenticator() => _authenticator;

  List<String> getChannels() => _channels;

  ConflictResolver getConflictResolver() => _conflictResolver;

  Database getDatabase() => database;

  List<String> getDocumentIDs() => _documentIDs;

  Map<String, String> getHeaders() => _headers;

  // byte[] getPinnedCertificate()

  ReplicationFilter getPullFilter() => _pullFilter;

  ReplicationFilter getPushFilter() => _pushFilter;

  ReplicatorType getReplicatorType() => _replicatorType;

  Endpoint getTarget() => target;

  bool isContinuous() => _continuous;

  ReplicatorConfiguration setAuthenticator(Authenticator authenticator) {
    _authenticator = authenticator;
    _fluttercouch.setReplicatorAuthenticator(_uuid, authenticator);
    return this;
  }

  ReplicatorConfiguration setChannels(List<String> channels) {
    _channels = this._channels;
    _fluttercouch.setReplicatorChannels(_uuid, channels);
    return this;
  }

  ReplicatorConfiguration setConflictResolver(ConflictResolver conflictResolver) {
    _conflictResolver = this._conflictResolver;
    _eventsStream.liste(_onEvent, _onEventError);
    return this;
  }

  ReplicatorConfiguration setContinuous(bool continuous) {
    _continuous = continuous;
    return this;
  }

  ReplicatorConfiguration setDocumentIDs(List<String> documentsIDs) {
    _documentIDs = documentsIDs;
    return this;
  }

  ReplicatorConfiguration setHeaders(Map<String, String> headers) {
    _headers = headers;
    return this;
  }

  /*ReplicatorConfiguration setPinnedServerCertificate(String pinnedServerCertificate) {
    return this;
  }*/

  ReplicatorConfiguration setPullFilter(ReplicationFilter pullFilter) {
    _pullFilter = _pullFilter;
    return this;
  }

  ReplicatorConfiguration setPushFilter(ReplicationFilter pushFilter) {
    _pushFilter = pushFilter;
    return this;
  }

  ReplicatorConfiguration setReplicatorType(ReplicatorType replicatorType) {
    _replicatorType = _replicatorType;
    return this;
  }
}

class _Fluttercouch extends Fluttercouch {}

enum ReplicatorType {
  PUSH,
  PULL,
  PUSH_AND_PULL
}

enum DocumentFlag {
  DocumentsFlagsAccessRemoved,
  DocumentFlagsDeleted
}