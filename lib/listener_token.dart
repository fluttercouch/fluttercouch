import 'package:uuid/uuid.dart';

class ListenerToken {
  /// Listener token returned when adding a change listener. The token is used for removing the added change listener.
  final String tokenId;

  ListenerToken([this.tokenId]);

  factory ListenerToken.v5(String namespace, String name) {
    ListenerToken result = new ListenerToken(new Uuid().v5(namespace, name));
    return result;
  }

  Map<String, dynamic> toJson() => {"token": tokenId};

  @override
  bool operator ==(other) {
    if (other is ListenerToken) {
      return tokenId == other.tokenId;
    }

    return false;
  }

  @override
  int get hashCode => tokenId.hashCode;
}
