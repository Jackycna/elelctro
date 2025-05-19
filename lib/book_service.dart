import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/confirmation_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  final List<Service> services = [
    Service("Laptop Chip Service", "assets/images/chip.jpeg"),
    Service("Laptop Repair", "assets/images/laptoprepair.jpg"),
    Service("Software Installation", "assets/images/softwareinstall.jpg"),
    Service("Printer Service", "assets/images/printer.jpeg"),
  ];

  final Map<String, bool> selectedServices = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String ownerid = "y1VDMu2Gooa35K6RUKRIatQ524w2";

  @override
  void initState() {
    super.initState();
    for (var service in services) {
      selectedServices[service.name] = false;
    }
  }

  void saveBooking() async {
    setState(() {
      isLoading = true;
    });
    final selected = selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selected.isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String userId = user.uid;
    String bookingDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User details not found."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Extract user details
      String userName = userDoc['name'] ?? "Unknown User";
      String userPhone = userDoc['phone'] ?? "No Phone";
      String address = userDoc['address'] ?? "No address";

      // Save booking
      await FirebaseFirestore.instance.collection("bookings").add({
        "userId": userId,
        "userName": userName,
        "userPhone": userPhone,
        "services": selected,
        "bookingDate": bookingDate,
        "address": address,
        "ownerId": ownerid,
        "status": 'pending',
        "liveLocation": {
          "latitude": 8.1833,
          "longitude": 77.4119,
        },
      });

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServiceBookedScreen()),
        // Removes everything except '/home'
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error saving booking: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking failed. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Services",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF40B7BA),
        elevation: 0,
      ),
      body: isLoading
          ? const CustomLoading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return ServiceCheckbox(
                          service: services[index],
                          isSelected: selectedServices[services[index].name]!,
                          onChanged: (value) {
                            setState(() {
                              selectedServices[services[index].name] = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: selectedServices.containsValue(true) ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: selectedServices.containsValue(true)
                            ? saveBooking
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF40B7BA),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ServiceCheckbox extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const ServiceCheckbox({
    required this.service,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                service.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  onChanged(value ?? false);
                },
                activeColor: const Color(0xFF40B7BA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String name;
  final String imagePath;

  Service(this.name, this.imagePath);
}
