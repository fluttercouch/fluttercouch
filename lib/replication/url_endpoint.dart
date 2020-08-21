import 'package:fluttercouch/replication/endpoint.dart';

class URLEndpoint extends Endpoint {
  Uri _uri;

  URLEndpoint(Uri uri) {
    this._uri = uri;
  }

  getURL() {
    return this._uri;
  }

  String toString() {
    return this._uri.toString();
  }
}