import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rehtracker_flutter/utils/auth.dart';

const BASE_URL = 'https://rehtracker.herokuapp.com';

class SignInResponse {
  String? cont = '';

  SignInResponse({required this.cont});

  factory SignInResponse.fromJSON(Map<String, dynamic> json) {
    return SignInResponse(cont: json['token']);
  }

  String? get content {
    return cont;
  }
}

Future<SignInResponse?> signIn(String username, String password) async {
  final res = await http.post(Uri.parse("$BASE_URL/api/auth/mobile/sign-in"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"username": username.trim(), "password": password}));
  if (res.statusCode == 200) {
    SignInResponse response = SignInResponse.fromJSON(jsonDecode(res.body));
    return response;
  } else {
    return null;
  }
}

Future<bool> signedIn() async {
  final token = await readAuthToken();

  if (token == null) {
    return false;
  }

  final res = await http.post(Uri.parse("$BASE_URL/api/auth/mobile/signed-in"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"token": token}));
  if (res.statusCode == 200) {
    bool response = jsonDecode(res.body);
    return response;
  } else {
    return false;
  }
}
