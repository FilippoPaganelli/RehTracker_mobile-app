import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<dynamic> readCredentials() async {
  if (await storage.containsKey(key: "username") == false) return null;
  String user = (await storage.read(key: "username"))!;
  String pass = (await storage.read(key: "password"))!;
  return Credentials(user, pass);
}

Future<dynamic> readAuthToken() async {
  // await storage.deleteAll();
  if (await storage.containsKey(key: "auth-token") == false) {
    print('-token not found');
    return '';
  }
  String tok = (await storage.read(key: "auth-token"))!;
  return tok;
}

Future<void> writeCredentials(String user, String pass) async {
  await storage.write(key: "username", value: user);
  await storage.write(key: "password", value: pass);
}

Future<void> writeAuthToken(String tok) async {
  await storage.write(key: "auth-token", value: tok);
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
