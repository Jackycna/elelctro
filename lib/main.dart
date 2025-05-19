import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:tecdona/auth_checker.dart';

import 'package:tecdona/localization_Service.dart';
import 'package:tecdona/Signin_Page.dart';
import 'package:tecdona/Splash_Screen.dart';
import 'package:tecdona/User_Details.dart';
import 'package:tecdona/privacy_polici.dart';
import 'package:tecdona/service_page.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message:${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyDNY5mWay3TqIB-25Zw6L0GI9L_yGWk46U",
      authDomain: "trenstecdona.firebaseapp.com",
      appId: "1:124817061862:web:dbeac8ed346ff427874827",
      databaseURL: "https://trenstecdona-default-rtdb.firebaseio.com",
      projectId: "trenstecdona",
      storageBucket: "trenstecdona.firebasestorage.app",
      messagingSenderId: "124817061862",
    ));
  } else {
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Recieved a foreground message:${message.messageId}');
    }
    if (message.notification != null) {
      if (kDebugMode) {
        print('Notification Title:${message.notification!.title}');
      }
      if (kDebugMode) {
        print('Notification Body:${message.notification!.body}');
      }
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Timer? updateTimer;
  String currentLanguage = 'ta';
  bool isCheckingUpdate = false;
  @override
  void initState() {
    super.initState();
    startPeriodicUpdateCheck();
    loadLanguage();
    FirebaseMessaging.instance.requestPermission();
    getDeviceToken();
    checkForUpdate();
  }

  Future<void> loadLanguage() async {
    String languageCode = await LocalizationService().getSavedLanguage();

    setState(() {
      currentLanguage = languageCode;
    });
    await LocalizationService().loadLanguage(currentLanguage);
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  void startPeriodicUpdateCheck() {
    updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkForUpdates();
    });
  }

  void checkForUpdates() {
    if (kDebugMode) {
      print("Checking for updates...");
    }
  }

  Future<void> getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tecdona',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate, // Add the localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English language
        Locale('ta', ''),
      ],
      localeResolutionCallback:
          (Locale? deviceLocale, Iterable<Locale> supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            // Load the selected language from assets
            LocalizationService().loadLanguage(locale.languageCode);
            return locale;
          }
        }
        // If the device locale is not supported, default to English (or Tamil, as you prefer)
        LocalizationService().loadLanguage('ta');
        return const Locale('ta');
      },
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/Auth': (context) => const AuthChecker(),
        '/sign_in': (context) => const SignInPage(),
        '/user': (context) => const UserDetailsPage(),
        '/home': (context) => const ServicePage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
      },
    );
  }

  Future<void> checkForUpdate() async {
    setState(() {
      isCheckingUpdate = true;
    });
    if (kDebugMode) {
      print('Checking for update...');
    }
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('Update available');
        }
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for update: ${e.toString()}');
      }
    } finally {
      setState(() {
        isCheckingUpdate = false;
      });
    }
  }

  void update() async {
    if (kDebugMode) {
      print('Updating...');
    }
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
      if (kDebugMode) {
        print('Update completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during update: ${e.toString()}');
      }
    }
  }
}
