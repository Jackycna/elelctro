import 'package:permission_handler/permission_handler.dart';

Future<void> _requestPermissions() async {
  if (await Permission.camera.isDenied) {
    await Permission.camera.request();
  }
  if (await Permission.photos.isDenied) {
    await Permission.photos.request();
  }
}
