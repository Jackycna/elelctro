import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

import 'package:tecdona/Loading_indicatoer.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final PageController _pageController = PageController();

  int _currentPage = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/images/chip.jpeg',
    'assets/images/laptoprepair.jpg',
    'assets/images/softwareinstall.jpg',
    'assets/images/printer.jpeg',
  ];

  String _verificationId = '';
  bool _otpSent = false;
  bool _isLoading = false;
  bool _otpVerified = false;

  @override
  void initState() {
    super.initState();

    // FocusNode listener
    _phoneFocusNode.addListener(() {
      setState(() {});
    });

    // Timer for auto-scrolling
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // Ensure the PageView has been fully initialized before calling animateToPage
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF40B7BA), Colors.white70],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const CustomLoading()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome Text
                          const Text(
                            "Welcome",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Sign in to continue",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),

                          // Card for Sign-In Details
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(19.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // PageView with Images
                                  SizedBox(
                                    height: 200,
                                    width: 180,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          onPageChanged: (int index) {
                                            setState(() {
                                              _currentPage = index;
                                            });
                                          },
                                          itemCount: _images.length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                _images[index],
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: _images
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                width: _currentPage == entry.key
                                                    ? 12.0
                                                    : 8.0,
                                                height: 8.0,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _currentPage == entry.key
                                                          ? Colors.blue
                                                          : Colors.grey[400],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Input Field
                                  _otpSent
                                      ? _buildOtpInputFields()
                                      : _buildPhoneInputField(),

                                  const SizedBox(height: 30),

                                  // Button
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          _otpSent ? _verifyOTP : _sendOTP,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF40B7BA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        _otpSent ? 'Verify OTP' : 'Send OTP',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_otpSent)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _otpSent = false;
                                  });
                                },
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                label: const Text(
                                  "Back",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Loading indicator with blurred background

  Widget _buildBackButton() {
    return Positioned(
      left: 16,
      top: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF003780)),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      focusNode: _phoneFocusNode,
      decoration: InputDecoration(
        labelText: 'Enter Mobile Number',
        labelStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        prefixText: _phoneFocusNode.hasFocus ? '+91 ' : '',
        hintStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFF40B7BA).withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOtpInputFields() {
    return Column(
      children: [
        Text(
          'OTP sent to: ${_phoneController.text.trim()}',
          style: const TextStyle(
              fontSize: 16, color: Colors.black, fontFamily: 'Roboto'),
        ),
        const SizedBox(height: 10),
        Pinput(
          length: 6,
          controller: _otpController,
          onCompleted: (otp) {
            _verifyOTP();
          },
          defaultPinTheme: PinTheme(
            width: 40,
            height: 40,
            textStyle: const TextStyle(fontSize: 18, color: Colors.black),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF40B7BA)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendOTP() async {
    String userInput = _phoneController.text.trim();
    String numericPhoneNumber = userInput.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericPhoneNumber.length != 10) {
      _showAlertDialog('Invalid Phone Number',
          'Please enter a valid 10-digit mobile number.');
      return;
    }

    String phoneNumber = '+91$numericPhoneNumber';

    // Check for test number
    const String testNumber = ''; // Replace with your desired test number
    if (numericPhoneNumber == testNumber) {
      _navigateTouser(); // Navigate directly to user page
      return;
    }

    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _otpVerified = true;
        await _checkUserDataExists();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        _showAlertDialog('Verification Error',
            e.message ?? 'An error occurred during verification.');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = false;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });
    String otp = _otpController.text.trim();

    if (_verificationId.isNotEmpty && otp.isNotEmpty) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      try {
        await _auth.signInWithCredential(credential);
        _otpVerified = true;
        await _checkUserDataExists();
        setState(() {
          _otpSent = false;
          _isLoading = false;
        });
      } catch (e) {
        // ignore: avoid_print
        print('Error verifying OTP: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _checkUserDataExists() async {
    if (!_otpVerified) return;

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        await _updateFCMToken(user.uid);
        _navigateToHomePage();
      } else {
        await _storeUserData(user.phoneNumber ?? user.uid);
        await _updateFCMToken(user.uid);
        _navigateTouser();
      }
    }
  }

  Future<void> _storeUserData(String phoneNumber) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'phone': phoneNumber,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<void> _updateFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (token != null && userDoc.exists) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  void _navigateToHomePage() {
    setState(() => _isLoading = false);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _navigateTouser() {
    setState(() => _isLoading = false);
    Navigator.pushNamedAndRemoveUntil(context, '/user', (route) => false);
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
  }
}
