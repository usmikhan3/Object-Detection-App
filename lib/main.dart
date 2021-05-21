import 'package:flutter/material.dart';
import 'package:object_detection_app/screens/home_screen.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detection App',
      home: HomeScreen(),
    );
  }
}

//   keytool -genkey -v -keystore D:\APPLICATIONS\OBJECTDETECT\keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

