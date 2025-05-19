import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(),
              const SizedBox(height: 0),
              Center(
                child: Image.asset(
                  'assets/images/we1.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Who We Are:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'TecDona specializes in computer chip-level repairs, laptop repairs, and printer repairs. Whether your laptop keyboard is broken, your display is damaged, or other components need attention, we ensure all issues are reworked perfectly.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our Services:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  serviceTile('Computer chip-level repairs'),
                  serviceTile('Laptop repairs'),
                  serviceTile('Printer repairs'),
                  serviceTile('Broken laptop rework'),
                  serviceTile('Keyboard and display repairs'),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/images/we2.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Why Choose Us?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'At TecDona, we are committed to providing reliable and high-quality repair services. Our experienced team ensures precision in every repair task, bringing your devices back to life.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget serviceTile(String service) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF40B7BA)),
          const SizedBox(width: 8),
          Text(
            service,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutUsPage(),
  ));
}
