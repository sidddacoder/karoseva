import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karoseva/caregiver_login_page.dart';  // ✅ Ensure correct import
import 'package:karoseva/caregiver_signup_page.dart'; // ✅ Ensure correct import
import 'package:karoseva/welcome_page.dart';
import 'package:karoseva/signup_page.dart';
import 'package:karoseva/login_page.dart';
import 'package:karoseva/create_profile_page.dart';
import 'package:karoseva/services_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KaroSevaApp());
}

class KaroSevaApp extends StatelessWidget {
  const KaroSevaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karo Seva',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        '/caregiver_signup': (context) => CaregiverSignupPage(), // ✅ Fixed Import
        '/caregiver_login': (context) => CaregiverLoginPage(),  // ✅ Fixed Import
        '/create_profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          if (args == null || !args.containsKey('userId')) {
            throw Exception('Missing required argument: userId');
          }
          return CreateProfilePage(userId: args['userId'] as String);
        },
        '/services': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          if (args == null || !args.containsKey('userId')) {
            throw Exception('Missing required argument: userId');
          }
          return ServicesPage(userId: args['userId'] as String);
        },
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
      },
    );
  }
}
