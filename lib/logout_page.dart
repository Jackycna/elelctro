import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  LogoutPageState createState() => LogoutPageState();
}

class LogoutPageState extends State<LogoutPage> {
  bool _isLoading = false;
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Define FirebaseAuth instance

  Future<void> _logOut() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Simulate a delay (optional, for user experience)
      await Future.delayed(const Duration(seconds: 1));

      // Clear any app-specific data if necessary
      // Example: SharedPreferences or local cache clearing

      // Navigate to the SignInPage
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/sign_in',
          (route) => false,
        );
      }
    } catch (e) {
      // Handle any errors during sign-out
      // print('Error during logout: $e');
      if (mounted) {
        _showAlertDialog(
            'Logout Error', 'Failed to log out. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'assets/images/logout.png',
                    height: 200,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Oh no! You are leaving...\n         Are you sure?',
                style: TextStyle(color: Color(0xFF40B7BA), fontSize: 26),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40B7BA),
                  side: const BorderSide(color: Color(0xFF40B7BA), width: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                ),
                child: const Text(
                  'Naah,just kidding',
                  style: TextStyle(color: Color(0xFFEae6de), fontSize: 24),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:
                    _isLoading ? null : _logOut, // Disable button while loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEae6de),
                  side: const BorderSide(color: Color(0xFF40B7BA), width: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF40B7BA)),
                      )
                    : const Text(
                        'Yes,log me out',
                        style:
                            TextStyle(color: Color(0xFF40B7BA), fontSize: 24),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
