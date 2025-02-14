import 'package:flutter/material.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/welcome_page.dart';
import 'package:project/pages/registration_page.dart';
import 'package:project/pages/verification_page.dart';
import 'package:project/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/verification') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => VerificationPage(email: args),
          );
        }
        return null;
      },
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
      },
    );
  }
}
