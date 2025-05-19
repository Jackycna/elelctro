import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/about%20us_page.dart';
import 'package:tecdona/book_page.dart';
import 'package:tecdona/logout_page.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isEditing = false;
  bool nonedit = false;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String photoUrl = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userId = currentUser.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            nameController.text = userDoc['name'] ?? '';
            phoneController.text = userDoc['phone'] ?? '';
            addressController.text = userDoc['address'] ?? '';
            photoUrl = userDoc['photoUrl'] ?? '';
          });
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  Future<void> saveUserDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error saving user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    setState(() {
      isLoading = true;
    });

    try {
      String fileName = 'profile_pictures/$userId.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
      });

      setState(() {
        photoUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: isLoading
            ? const CustomLoading()
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: const BoxDecoration(
                                color: Color(0xFF40B7BA),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(100),
                                  bottomRight: Radius.circular(90),
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Stack(
                                    children: [
                                      Container(
                                        width: 120, // Same as radius * 2
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 4),
                                          image: DecorationImage(
                                            image: photoUrl.isNotEmpty
                                                ? NetworkImage(photoUrl)
                                                : const AssetImage(
                                                        'assets/images/place.png')
                                                    as ImageProvider,
                                            fit: BoxFit
                                                .fill, // Ensures the image covers the entire circle
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: updateProfileImage,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.teal,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: const Icon(Icons.camera_alt,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    nameController.text.isEmpty
                                        ? "User Name"
                                        : nameController.text,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildEditableField(
                            Icons.person, 'Name', nameController, isEditing),
                        _buildEditableField(
                            Icons.phone, 'Phone no.', phoneController, nonedit),
                        _buildEditableField(Icons.location_on_rounded,
                            'Address', addressController, isEditing),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 30),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          nonedit = false;
                        });
                        if (isEditing) {
                          saveUserDetails();
                        }
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Drawer Widget
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF40B7BA),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/images/english.jpg')
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  nameController.text.isEmpty
                      ? "User Name"
                      : nameController.text,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
              Icons.list_outlined, "Bookings", context, const BookPage()),
          _buildDrawerItem(Icons.help, "About us", context, AboutUsPage()),
          _buildDrawerItem(Icons.logout, "Logout", context, const LogoutPage()),
        ],
      ),
    );
  }

  // Drawer Item Widget
  Widget _buildDrawerItem(
      IconData icon, String title, BuildContext context, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Widget _buildEditableField(IconData icon, String label,
      TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
