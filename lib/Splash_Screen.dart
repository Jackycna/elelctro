import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Import the device info package
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tecdona/Loading_indicatoer.dart';

import 'package:tecdona/localization_Service.dart';
import 'package:tecdona/Signin_Page.dart';
import 'package:tecdona/service_page.dart';
import 'package:video_player/video_player.dart'; // Import in_app_update for update functionality

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool isOffline = false;
  bool _isEmulator = false;
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectivityStatus(result.first);
    });
    controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });
    _checkIfEmulator();
    Future.microtask(() => _navigateToNextScreen());
  }

  // Check if the app is running on an emulator
  Future<void> _checkIfEmulator() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceData = await deviceInfoPlugin.androidInfo;

    setState(() {
      _isEmulator = deviceData.isPhysicalDevice ==
          false; // If it's not a physical device, it's an emulator
    });
  }

  // Check initial connectivity status
  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  // Update connectivity status on network changes
  void _updateConnectivityStatus(ConnectivityResult result) {
    if (!mounted) {
      return;
    }

    setState(() {
      isOffline = result == ConnectivityResult.none;
    });

    if (isOffline && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NoNetworkPage()),
      );
    }
  }

  // Handle the update flow
  Future<void> checkForUpdate() async {
    if (_isEmulator) {
      // If the app is running on an emulator, skip the update check
      return;
    }

    // Proceed with in-app update check for real devices
    try {
      // Correct way to access the static method
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // print("In-app update check failed: $e");
    }
  }

  // Navigate to next screen based on network and authentication status
  Future<void> _navigateToNextScreen() async {
    if (isOffline) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NoNetworkPage()),
        );
      }
      return;
    }

    bool isFirstLaunch = await SharedPreferencesHelper.isFirstLaunch();
    User? user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 7));

    if (!mounted) {
      return;
    }

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ServicePage()),
      );
    } else if (isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    controller.dispose(); // Dispose of the controller properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const CircularProgressIndicator(), // Show a loading indicator until the video is ready
      ),
    );
  }
}

class NoNetworkPage extends StatefulWidget {
  const NoNetworkPage({super.key});

  @override
  NoNetworkPageState createState() => NoNetworkPageState();
}

class NoNetworkPageState extends State<NoNetworkPage> {
  bool _isCheckingConnectivity = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/nonetwork.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setLooping(true);
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isCheckingConnectivity = true;
    });

    bool hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _isCheckingConnectivity = false;
      });
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controller.value.isInitialized
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.45,
                        child: VideoPlayer(_controller),
                      )
                    : const CustomLoading(),
                const SizedBox(height: 20),
                Text(
                  LocalizationService().translate('nonet'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40B7BA),
                  ),
                  onPressed:
                      _isCheckingConnectivity ? null : _checkConnectivity,
                  child: Text(
                    LocalizationService().translate('retry'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_isCheckingConnectivity)
            Stack(
              children: [
                ModalBarrier(
                  color: Colors.black.withOpacity(0.5),
                  dismissible: false,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SharedPreferencesHelper {
  static const String isFirstLaunchKey = 'is_first_launch';

  // Check if it's the first launch
  static Future<bool> isFirstLaunch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch =
        prefs.getBool(isFirstLaunchKey) ?? true; // Default is true

    if (isFirstLaunch) {
      // After the first launch, update the preference
      await prefs.setBool(isFirstLaunchKey, false);
    }

    return isFirstLaunch;
  }

  // Optionally, store sign-in status if required
  static Future<void> setSignedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isFirstLaunchKey, false); // User is no longer new
  }
}
