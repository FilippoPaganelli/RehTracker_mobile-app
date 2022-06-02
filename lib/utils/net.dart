import 'dart:convert';
import 'package:http/http.dart' as http;

const serverIP = 'https://rehtracker.herokuapp.com/';

Future<MyResponse?> attemptLogIn(String username, String password) async {
  var res = await http.post(
      Uri.parse("https://rehtracker.herokuapp.com/api/auth/mobile/sign-in"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"username": username.trim(), "password": password}));
  if (res.statusCode == 200) {
    MyResponse myres = MyResponse.fromJSON(jsonDecode(res.body));
    return myres;
  } else {
    return null;
  }
}

class MyResponse {
  String cont = '';

  MyResponse({required this.cont});

  factory MyResponse.fromJSON(Map<String, dynamic> json) {
    return MyResponse(cont: json['token']);
  }

  String get content {
    return cont;
  }
}
