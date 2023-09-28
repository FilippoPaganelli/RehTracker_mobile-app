import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
const authTokenKey = "auth-token";

Future<void> deleteAuthToken() async {
  await storage.delete(key: authTokenKey);
}

Future<String?> readAuthToken() async {
  String? token = await storage.read(key: authTokenKey);

  return token;
}

Future<void> writeCredentials(String username, String password) async {
  await storage.write(key: "username", value: username);
  await storage.write(key: "password", value: password);
}

Future<void> writeAuthToken(String token) async {
  await storage.write(key: authTokenKey, value: token);
}

class AuthToken {
  String tok = '';

  AuthToken(this.tok);

  String get token {
    return tok;
  }
}

class Credentials {
  String user = '';
  String pass = '';

  Credentials(this.user, this.pass);

  String get username {
    return user;
  }

  String get password {
    return pass;
  }
}
