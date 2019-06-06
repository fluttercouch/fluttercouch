import 'package:uuid/uuid.dart';

class ListenerToken {
  final tokenId = Uuid().v1();

  ListenerToken();

  Map<String, dynamic> toJson() => {"token":tokenId};

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