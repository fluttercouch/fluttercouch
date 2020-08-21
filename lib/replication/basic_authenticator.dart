import 'authenticator.dart';

class BasicAuthenticator extends Authenticator {
  final String username;
  final String password;

  BasicAuthenticator(this.username, this.password);

  String getUsername() => username;

  String getPassword() => password;
}