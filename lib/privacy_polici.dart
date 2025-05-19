import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your privacy is important to us. This privacy policy document outlines the types of personal information that is received and collected by our application and how it is used.\n\n'
                '1. Information We Collect\n'
                '- Personal information such as name, email, and contact details provided by users.\n'
                '- Usage data including app interactions and preferences.\n\n'
                '2. How We Use Information\n'
                '- To provide and improve our services.\n'
                '- To communicate with users regarding updates and support.\n\n'
                '3. Data Protection\n'
                '- We implement security measures to safeguard user data.\n'
                '- We do not share personal information with third parties without consent.\n\n'
                'For further details, please contact us at support@example.com.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
