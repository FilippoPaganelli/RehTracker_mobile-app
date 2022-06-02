// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rehtracker_flutter/utils/auth.dart';

import '../utils/colours.dart' as colours;
import '../utils/net.dart';
import 'dashboard.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

Widget _buildUsernameInput(TextEditingController _usernameController) {
  return (Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextField(
            controller: _usernameController,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.co_present,
                  color: colours.GRADIENT_2,
                ),
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.black38)),
          ))
    ],
  ));
}

Widget _buildPasswordInput(TextEditingController _passwordController) {
  return (Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.lock_rounded,
                  color: colours.GRADIENT_2,
                ),
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.black38)),
          ))
    ],
  ));
}

void displayDialog(BuildContext context, String title, String text) =>
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );

Widget _buildSigninButton(
    BuildContext context,
    TextEditingController _usernameController,
    TextEditingController _passwordController) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        var username = _usernameController.text;
        var password = _passwordController.text;
        MyResponse? res = await attemptLogIn(username, password);
        if (res == null) {
          displayDialog(
              context, "Error", "Wrong username or password, try again.");
        } else {
          writeAuthToken(res.content).then((value) => print('-token saved'));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      },
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          primary: Colors.white,
          padding: const EdgeInsets.all(15)),
      child: const Text(
        'Sign in',
        style: TextStyle(color: colours.GRADIENT_2, fontSize: 23),
      ),
    ),
  );
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final Image logo;

  @override
  void initState() {
    logo = Image.asset(
      'assets/logo_full_transp_bg.png',
      scale: 5,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colours.GRADIENT_1,
                        colours.GRADIENT_2,
                        colours.GRADIENT_3,
                        colours.GRADIENT_4
                      ],
                    ),
                  ),
                  child: Center(
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 50, vertical: 150),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 125,
                          width: 300,
                          child: logo,
                        ),
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: _buildUsernameInput(_usernameController),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: _buildPasswordInput(_passwordController),
                        ),
                        const SizedBox(height: 100),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: _buildSigninButton(context,
                              _usernameController, _passwordController),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
