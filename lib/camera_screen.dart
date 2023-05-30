import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'photo_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  LocationData? _locationData;
  List<double> _accelerometerValues = <double>[];
  List<double> _gyroscopeValues = <double>[];
  List<double> _magnetometerValues = <double>[];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeLocation();
    _startListeningToSensors();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location service is disabled');
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        print('Location permission denied');
        return;
      }
    }

    location.onLocationChanged.listen((LocationData result) {
      setState(() {
        _locationData = result;
      });
    });
  }

  void _startListeningToSensors() {
    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });

    // Listen to gyroscope events
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });

    // Listen to magnetometer events
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      });
    });
  }

  Future<void> _captureImage() async {
    if (_controller!.value.isInitialized) {
      try {
        final file = await _controller!.takePicture();
        print('Image captured: ${file.path}');
        _navigateToPhotoScreen(file.path);
      } catch (e) {
        print('Error capturing image: $e');
        return;
      }
    }
  }

  void _navigateToPhotoScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoScreen(
          imagePath: imagePath,
          locationData: _locationData,
          accelerometerValues: _accelerometerValues,
          gyroscopeValues: _gyroscopeValues,
          magnetometerValues: _magnetometerValues,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FireBird'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: CameraPreview(_controller!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
