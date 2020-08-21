import 'authenticator.dart';

class SessionAuthenticator extends Authenticator {
  String _sessionID;
  String _cookieName;

  SessionAuthenticator(String sessionID, {String cookieName}) {
    _sessionID = sessionID;
    _cookieName = cookieName;
  }

  String getCookieName() => _cookieName;

  String getSessionID() => _sessionID;
}