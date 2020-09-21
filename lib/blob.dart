import 'dart:io';
import 'dart:typed_data';

/// Blob is nothing but an attachment introduced in Couchbase List 2.x.
/// Read about blobs: [Java](https://docs.couchbase.com/couchbase-lite/2.5/java.html#blobs)/[Swift](https://docs.couchbase.com/couchbase-lite/2.5/swift.html#blobs).
///
/// It accepts a [_uniqueName] and a stream of [_bytes] that act as the unique
/// identifier to access the data and data that is to be stored in the attachment
/// respectively.
class Blob {
  /// Unique name that can be used to retrieve the blob data from the document.
  String _uniqueName;

  /// Content type / MIME type of the blob.
  String _contentType;

  /// Attachment data in the form of steam of bytes.
  Uint8List _bytes;

  /// Default constructor.
  Blob(this._uniqueName, this._contentType, this._bytes);

  /// Creates a blob object based on the [uniqueName], [contentType] and [file] provided.
  Blob.fromFile(String uniqueName, String contentType, File file) {
    _readBytesFromFile() async => await file.readAsBytes();

    this._uniqueName = uniqueName;
    this._contentType = contentType;

    _readBytesFromFile().then((bytes) {
      this._bytes = bytes;
    }).catchError((error) {
      print(error.toString());
      throw Exception("""
      Failed to convert the file to a byte stream.
      File: $file
      Path: ${file.path}
      """);
    });
  }

  /// Returns the unique name specified for the [Blob].
  String getUniqueName() => _uniqueName;

  /// Returns the content-type of the [Blob].
  String getContentType() => _contentType;

  /// Returns the data in the form of a byte stream.
  Uint8List getData() => _bytes;
}

/// Exception that is throws when either the unique name or the byte stream of the
/// blob are null or empty respectively.
class CorruptBlobException implements Exception {
  final message;

  const CorruptBlobException([this.message = "Invalid Blob object provided."]);
}
