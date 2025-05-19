import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/order_success.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String userId;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  ProductDetailsScreenState createState() => ProductDetailsScreenState();
}

class ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = false;
  String? userAddress;
  String ownerid = "y1VDMu2Gooa35K6RUKRIatQ524w2";

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userAddress = userDoc['address'] ?? "No address available";
        });
      }
    } catch (e) {
      setState(() {
        userAddress = "Failed to load address";
      });
    }
  }

  void orderNow(BuildContext context) async {
    if (userAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address is still loading. Please wait.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    CollectionReference orders =
        FirebaseFirestore.instance.collection('productbookings');

    await orders.add({
      'userId': widget.userId,
      'productName': widget.product['name'],
      'price': widget.product['price'],
      'image': widget.product['imageUrl'],
      'features': widget.product['features'],
      'address': userAddress,
      'timestamp': FieldValue.serverTimestamp(),
      'ownerId': ownerid,
      'status': 'pending',
      "liveLocation": {
        "latitude": 8.1833,
        "longitude": 77.4119,
      },
    });

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CustomLoading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Product Details',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF40B7BA),
              elevation: 4,
              shadowColor: Colors.black26,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.product['imageUrl'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard("Price", "\$${widget.product['price']}",
                      Icons.currency_rupee_sharp),
                  _buildInfoCard(
                      "Features",
                      widget.product['features'] ?? "No features available",
                      Icons.list),
                  _buildInfoCard("Delivery Address",
                      userAddress ?? "Loading address...", Icons.location_on),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => orderNow(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF40B7BA),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.black38,
                        elevation: 4,
                      ),
                      child: const Text(
                        "Order Now",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
