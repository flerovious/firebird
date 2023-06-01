import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure that there's at least one camera available
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    print('No cameras available');
    return;
  }
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
        ),
      ),
      home: CameraScreen(camera: camera),
      debugShowCheckedModeBanner: false,
    );
  }
}
