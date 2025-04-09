import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal Scan AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DM Sans',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LaunchRouter(),
    );
  }
}

class LaunchRouter extends StatefulWidget {
  const LaunchRouter({super.key});

  @override
  State<LaunchRouter> createState() => _LaunchRouterState();
}

class _LaunchRouterState extends State<LaunchRouter> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('hasLaunched') ?? false;

    if (!hasLaunched) {
      await prefs.setBool('hasLaunched', true);
    }

    setState(() {
      _isFirstLaunch = !hasLaunched;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLaunch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isFirstLaunch!) {
      return const StartPage();
    }

    return const AuthWrapper();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
