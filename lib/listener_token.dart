import 'package:uuid/uuid.dart';

class ListenerToken {
  /// Listener token returned when adding a change listener. The token is used for removing the added change listener.
  String tokenId;

  ListenerToken();

  factory ListenerToken.v5(String namespace, String name) {
    ListenerToken result = new ListenerToken();
    result.tokenId = new Uuid().v5(namespace, name);
    return result;
  }

  factory ListenerToken.fromToken(String token) {
    ListenerToken result = new ListenerToken();
    result.tokenId = token;
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
