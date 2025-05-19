import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/home_Page.dart';
import 'package:image_picker/image_picker.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? userId;
  bool _isLoading = false;
  Map<String, dynamic> initialData = {};
  XFile? userImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;
    });
    if (userId != null) {
      loadUserDetails();
    }
  }

  Future<void> loadUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        initialData = userDoc.data() as Map<String, dynamic>;

        // Set the initial data into controllers
        _nameController.text = initialData['name'] ?? '';
        _phoneController.text = initialData['phone'] ?? '';
        _addressController.text = initialData['address'] ?? '';

        // Load the image URL (if available)
        String? imageUrl = initialData['photoUrl'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Save imageUrl for later use in the UI
          setState(() {
            profileImageUrl =
                imageUrl; // Assume you have a variable _profileImageUrl
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user details: $e')),
        );
      }
    }
  }

  Future<void> pickUserImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource
          .gallery, // You can use ImageSource.camera for taking photos
    );

    setState(() {
      userImage = pickedFile;
    });
  }

  Future<void> saveUserDetails() async {
    if (userId == null) return;

    if (_nameController.text.trim().isEmpty ||
        _nameController.text.trim().length < 5) {
      showAlertDialog(
          'Input Error', 'Name must be at least 5 characters long.');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      showAlertDialog('Input Error', 'Address is required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch owner ID where `address` matches the selected shop location

      // Fetch existing user data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'detailsSaved': true,
        'photoUrl': userImage?.path, // Store photo URL/path
      };

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> existingData =
            userDoc.data() as Map<String, dynamic>;
        if (existingData.containsKey('fcmToken')) {
          userData['fcmToken'] = existingData['fcmToken'];
        }
      }

      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));

      // Navigate to the Language Selection Page

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Nav()),
      );

      // Show success message
      showAlertDialog("Success", "User details saved successfully.");
    } catch (e) {
      debugPrint("Error saving user details: $e");
      showAlertDialog("Error", "Failed to save user details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveDetailsState(bool state) async {
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {
          'detailsSaved': state,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error updating detailsSaved state: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFF40B7BA),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? const CustomLoading()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Image Section placed above the card
                    _buildUserImageSection(),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            buildTextField(
                                controller: _nameController, label: 'Name'),
                            const SizedBox(height: 25),
                            buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 40),
                            buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              keyboardType: TextInputType.streetAddress,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: saveUserDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF40B7BA),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Save',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        filled: true,
        fillColor: const Color(0xFF40B7BA).withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<String?> uploadImageToStorage(XFile imageFile) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_photos/${userId}_${DateTime.now().millisecondsSinceEpoch}');

      // Upload the file
      final uploadTask = storageRef.putFile(File(imageFile.path));

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Widget _buildUserImageSection() {
    return GestureDetector(
      onTap: pickUserImage, // Allow user to pick an image
      child: Container(
        height: 150, // Adjusted for better visibility
        width: 150, // Make it square for a circular display
        decoration: BoxDecoration(
          color: const Color(0xFF40B7BA).withOpacity(0.2),
          borderRadius: BorderRadius.circular(
              75), // Half of the height/width for a perfect circle
        ),
        child: ClipOval(
          child: userImage != null && File(userImage!.path).existsSync()
              ? Image.file(
                  File(userImage!.path), // Load picked image
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                )
              : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? Image.network(
                      profileImageUrl!, // Load image from Firestore
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
        ),
      ),
    );
  }

  /// Placeholder widget for when no image is available
  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 40,
            color: Color(0xFF40B7BA),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
