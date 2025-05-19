import 'package:flutter/material.dart';
import 'package:tecdona/bookings_page.dart';
import 'package:tecdona/product_bookings.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose an Option",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            ImageCard(
              imagePath: "assets/images/chip.jpeg",
              label: "Service Bookings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ImageCard(
              imagePath: "assets/images/product.jpg",
              label: "Product Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductBookingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const ImageCard({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
