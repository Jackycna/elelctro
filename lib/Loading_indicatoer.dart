import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomLoading extends StatefulWidget {
  const CustomLoading({super.key});

  @override
  CustomLoadingState createState() => CustomLoadingState();
}

class CustomLoadingState extends State<CustomLoading> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset('assets/videos/loading.mp4')
      ..setLooping(true)
      ..initialize().then((_) {
        controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
