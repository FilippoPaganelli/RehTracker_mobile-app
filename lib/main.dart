import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehtracker_flutter/pages/dashboard.dart';
import 'pages/signin.dart';
import './utils/colours.dart' as colours;

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/sign-in',
      routes: {
        '/': (context) => const Dashboard(),
        '/sign-in': (context) => const SigninScreen()
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: colours.GRADIENT_2,

        // Define the default font family.
        fontFamily: GoogleFonts.sora().fontFamily,

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(),
      ),
    );
  }
}
