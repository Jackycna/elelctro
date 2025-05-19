import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.asset('assets/images/okconfirm.png'),
                const SizedBox(height: 20), // Removed duplicate SizedBox
                const Text(
                  'Your order is booked! Our service partner will contact you soon.\n\nThank you for choosing us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF40B7BA), // Change button color
                    foregroundColor: Colors.white,
                    elevation: 8, // Change text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
