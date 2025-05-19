import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/product_details.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    List<Map<String, dynamic>> allProducts = [];

    QuerySnapshot ownersSnapshot =
        await FirebaseFirestore.instance.collection('owners').get();

    for (var ownerDoc in ownersSnapshot.docs) {
      QuerySnapshot productsSnapshot =
          await ownerDoc.reference.collection('products').get();

      for (var productDoc in productsSnapshot.docs) {
        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;
        allProducts.add(productData);
      }
    }
    return allProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: FutureBuilder(
        future: fetchAllProducts(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoading());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Image.asset(
                'assets/images/tamil.png',
                width: 150,
                height: 150,
              ),
            );
          }

          var products = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Stack(
                              children: [
                                const Center(
                                    child:
                                        CircularProgressIndicator()), // Placeholder while loading
                                FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/pplace.png',
                                  image: product['imageUrl'],
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
