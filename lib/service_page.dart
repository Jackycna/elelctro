import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tecdona/book_page.dart';
import 'package:tecdona/book_service.dart';
import 'package:tecdona/Loading_indicatoer.dart';
import 'package:tecdona/products_page.dart';
import 'package:tecdona/sample_page.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<Service> services = [
    Service("Laptop Chip Service", "assets/videos/chiplevel.mp4",
        "We provide expert chip-level service for laptops, ensuring high performance."),
    Service("Laptop Repair", "assets/videos/laptoprepair.mp4",
        "Our professionals handle all laptop repairs with precision and care."),
    Service("Software Installation", "assets/videos/chiplevel.mp4",
        "We install and configure essential software for your needs."),
    Service("Printer Service", "assets/videos/printer.mp4",
        "We offer a variety of other Printer-related services.")
  ];

  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  void checkUserAuthentication() async {
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
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF40B7BA),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset("assets/images/techlogo.jpg",
                width: 40, height: 40, fit: BoxFit.cover),
          ),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductsScreen()),
                  );
                },
                child: Column(
                  children: [
                    Image.asset("assets/images/gadgets1.png",
                        width: 35, height: 35),
                    const Text("Products",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookPage()),
                  );
                },
                child: Column(
                  children: [
                    Image.asset("assets/images/booking.png",
                        width: 35, height: 35),
                    const Text("Bookings",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePages()),
                  );
                },
                child: Column(
                  children: [
                    Image.asset("assets/images/profile.png",
                        width: 35, height: 35),
                    const Text("Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            return ServiceContainer(services[index]);
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF40B7BA),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
          ),
          child: const Text(
            "Book a Service",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ServiceContainer extends StatelessWidget {
  final Service service;

  const ServiceContainer(this.service, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 350,
        width: 100,
        margin: const EdgeInsets.symmetric(vertical: 25),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: VideoPlayerWidget(videoPath: service.imagePath),
            ),
            const SizedBox(height: 10),
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40B7BA),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              service.description,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

ValueNotifier<String?> activeVideoNotifier = ValueNotifier<String?>(null);

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("Video Player Error: $error");
        }
      });

    activeVideoNotifier.addListener(_updatePlayback);
  }

  @override
  void dispose() {
    activeVideoNotifier.removeListener(_updatePlayback);
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibilityChange(VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      activeVideoNotifier.value = widget.videoPath; // Set this video as active
    }
  }

  void _updatePlayback() {
    if (activeVideoNotifier.value == widget.videoPath) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoPath),
      onVisibilityChanged: _handleVisibilityChange,
      child: _controller.value.isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : const SizedBox(
              height: 150,
              child: Center(child: CustomLoading()),
            ),
    );
  }
}

class Service {
  final String name;
  final String imagePath;
  final String description;

  Service(this.name, this.imagePath, this.description);
}
