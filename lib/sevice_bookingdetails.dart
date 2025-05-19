import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool isUpdating = false;
  bool locationUpdated = false;
  LatLng? currentLocation;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _loadExistingLocation();
  }

  void _loadExistingLocation() {
    var locationData = widget.booking['liveLocation'];
    if (locationData != null &&
        locationData['latitude'] != null &&
        locationData['longitude'] != null) {
      setState(() {
        currentLocation =
            LatLng(locationData['latitude'], locationData['longitude']);
        locationUpdated = true;
      });
    }
  }

  Future<void> _updateLiveLocation() async {
    setState(() => isUpdating = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.booking.id)
          .update({
        'liveLocation': {
          'latitude': newLocation.latitude,
          'longitude': newLocation.longitude
        },
      });

      setState(() {
        currentLocation = newLocation;
        locationUpdated = true; // Disable update button and show edit button
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(newLocation));
      }

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update location: $e')),
      );
    }

    setState(() => isUpdating = false);
  }

  void _confirmReuploadLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Do you want to re-upload your live location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateLiveLocation();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your location was updated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialLocation =
        currentLocation ?? const LatLng(37.7749, -122.4194); // Default location

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Date: ${widget.booking['bookingDate']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _infoRow(Icons.person, 'Name', widget.booking['userName']),
                    _infoRow(Icons.phone, 'Phone', widget.booking['userPhone']),
                    _infoRow(Icons.location_on, 'Address',
                        widget.booking['address']),
                    const SizedBox(height: 10),
                    const Text('Services:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8.0,
                      children: (widget.booking['services'] as List<dynamic>)
                          .map((service) => Chip(label: Text(service)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Live Location:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: initialLocation, zoom: 14),
                  markers: {
                    if (currentLocation != null)
                      Marker(
                          markerId: const MarkerId('liveLocation'),
                          position: currentLocation!)
                  },
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: locationUpdated
                  ? ElevatedButton.icon(
                      onPressed: _confirmReuploadLocation,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit your Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: isUpdating ? null : _updateLiveLocation,
                      icon: const Icon(Icons.location_on),
                      label: isUpdating
                          ? const CircularProgressIndicator()
                          : const Text('Update Live Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
