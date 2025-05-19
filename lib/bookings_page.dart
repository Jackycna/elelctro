import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tecdona/sevice_bookingdetails.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  BookingsPageState createState() => BookingsPageState();
}

class BookingsPageState extends State<BookingsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to booking details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingDetailsPage(booking: booking),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Date: ${booking['bookingDate']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blueGrey),
                            const SizedBox(width: 5),
                            Text(
                              'Name: ${booking['userName']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.green),
                            const SizedBox(width: 5),
                            Text(
                              'Phone: ${booking['userPhone']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Address: ${booking['address']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to see details',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
