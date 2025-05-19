import 'package:flutter/material.dart';
import 'package:tecdona/home_Page.dart';
import 'package:tecdona/localization_Service.dart';

class LanguageSelectionPage extends StatefulWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectionPage({super.key, required this.onLanguageSelected});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String selectedLanguage = ''; // Default language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Choose Language',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // English language selection
            Row(
              children: [
                SizedBox(
                  height: 200,
                  width: 170,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'ta'; // Set language to English
                      });
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/images/tamil.png'), // English Image
                        const SizedBox(height: 10),
                        const Text(
                          'தமிழ்',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // Checkmark for selected language
                        if (selectedLanguage == 'ta')
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),

                // Tamil language selection
                SizedBox(
                  height: 200,
                  width: 95,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = 'en'; // Set language to Tamil
                      });
                    },
                    child: Column(
                      children: [
                        Image.asset(
                            'assets/images/english3.jpg'), // Tamil Image
                        const SizedBox(height: 10),
                        const Text(
                          'English',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // Checkmark for selected language
                        if (selectedLanguage == 'en')
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onLanguageSelected(selectedLanguage);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const Nav()), // Replace with your first page
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40B7BA),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                LocalizationService().translate('save'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
