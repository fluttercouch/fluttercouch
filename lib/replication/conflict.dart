import '../document.dart';

class Conflict {
  final String documentId;
  final Document localDocument;
  final Document remoteDocument;

  Conflict(this.documentId, this.localDocument, this.remoteDocument);

  String getDocumentId() => documentId;
  Document getLocalDocument() => localDocument;
  Document getRemoteDocument() => remoteDocument;
}