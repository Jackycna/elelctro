import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  AuthCheckerState createState() => AuthCheckerState();
}

class AuthCheckerState extends State<AuthChecker> {
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to the authentication state changes
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User is signed in, navigate to home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is signed out, navigate to sign-in page
        Navigator.pushReplacementNamed(context, '/sign_in');
      }
    });
  }

  @override
  void dispose() {
    // Cancel the auth state subscription when the widget is disposed
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.black),
    );
  }
}
