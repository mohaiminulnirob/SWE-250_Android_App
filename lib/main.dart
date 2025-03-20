import 'package:flutter/material.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/welcome_page.dart';
import 'package:project/pages/verification_page.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
          final args = settings.arguments;
          if (args is Map<String, String>) {
            return MaterialPageRoute(
              builder: (context) => VerificationPage(
                username: args['username']!,
                email: args['email']!,
                registration: args['registration']!,
                password: args['password']!,
              ),
            );
          }
        }
        return null;
      },
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
