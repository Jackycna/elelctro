import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tecdona/products_page.dart';
import 'package:tecdona/sample_page.dart';
import 'package:tecdona/service_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Nav> {
  int _currentIndex = 0;
  User? _user;

  final List<Widget> _pages = [
    ServicePage(),
    const ProductsScreen(),
    const ProfilePages(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  void _checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/sign_in');
      });
    } else {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        bool? detailsSave = data['detailsSaved'];

        if (detailsSave == false || detailsSave == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/user');
          });
        }
      }
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _user != null
          ? _pages[_currentIndex]
          : const SizedBox(height: double.infinity, width: double.infinity),
      bottomNavigationBar: _user != null
          ? CurvedNavigationBar(
              backgroundColor: Colors.white,
              color: const Color(0xFF40B7BA),
              buttonBackgroundColor: const Color(0xFF003780),
              height: 60,
              animationDuration: const Duration(milliseconds: 500),
              animationCurve: Curves.easeInOut,
              index: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                Icon(Icons.home, size: 30, color: Colors.white),
                Icon(Icons.shopping_bag, size: 30, color: Colors.white),
                Icon(Icons.person, size: 30, color: Colors.white),
              ],
            )
          : null,
    );
  }
}
