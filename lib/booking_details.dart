import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tecdona/Loading_indicatoer.dart';

class ProductBookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const ProductBookingDetailsPage({super.key, required this.bookingId});

  @override
  State<ProductBookingDetailsPage> createState() =>
      _ProductBookingDetailsPageState();
}

class _ProductBookingDetailsPageState extends State<ProductBookingDetailsPage> {
  LatLng? liveLocation;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchLiveLocation();
  }

  Future<void> fetchLiveLocation() async {
    DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('productbookings')
        .doc(widget.bookingId)
        .get();

    if (bookingSnapshot.exists) {
      var data = bookingSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('liveLocation')) {
        setState(() {
          liveLocation = LatLng(
            data['liveLocation']['latitude'],
            data['liveLocation']['longitude'],
          );
        });
      }
    }
  }

  Future<void> updateLiveLocation() async {
    setState(() => isUpdating = true);

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng newLocation = LatLng(position.latitude, position.longitude);

    await FirebaseFirestore.instance
        .collection('productbookings')
        .doc(widget.bookingId)
        .update({
      'liveLocation': {
        'latitude': newLocation.latitude,
        'longitude': newLocation.longitude
      },
    });

    setState(() {
      liveLocation = newLocation;
      isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live location updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('productbookings')
            .doc(widget.bookingId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoading());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Booking details not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Product Details Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image,
                                    size: 40, color: Colors.redAccent),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['productName'] ?? 'Unknown Product',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Price: ₹${data['price'] ?? 'N/A'}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Address: ${data['address'] ?? 'N/A'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${data['status'] ?? 'Pending'}",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: data['status'] == 'Confirmed'
                                        ? Colors.green
                                        : Colors.orange),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Address: ${data['address'] ?? 'N/A'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Live Location Card
                // Live Location Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Location",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: liveLocation != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: liveLocation!,
                                      zoom: 14,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId:
                                            const MarkerId('liveLocation'),
                                        position: liveLocation!,
                                      ),
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "Your live location that will help us find you soon",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Conditionally show expected delivery date
                        if (data.containsKey('deliveryDate') &&
                            data['deliveryDate'] != null &&
                            data['deliveryDate'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Expected Delivery Date: ${data['deliveryDate']}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Update/Edit Live Location Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: liveLocation == null
                                ? Colors.teal
                                : Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  if (liveLocation == null) {
                                    await updateLiveLocation();
                                  } else {
                                    bool confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Edit Your Location"),
                                        content: const Text(
                                            "Are you sure you want to update your live location?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm) {
                                      await updateLiveLocation();
                                    }
                                  }
                                },
                          child: isUpdating
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  liveLocation == null
                                      ? "Upload Live Location"
                                      : "Edit your Location",
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
