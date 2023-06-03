import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class PhotoScreen extends StatefulWidget {
  final String imagePath;
  final LocationData? locationData;
  final List<double> accelerometerValues;
  final List<double> gyroscopeValues;
  final List<double> magnetometerValues;

  const PhotoScreen({
    Key? key,
    required this.imagePath,
    required this.locationData,
    required this.accelerometerValues,
    required this.gyroscopeValues,
    required this.magnetometerValues,
  }) : super(key: key);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  String description = '';

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);
    final lastModified = file.lastModifiedSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report wildfire'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(file),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Add description...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                FloatingActionButton(
                  onPressed: () {
                    print('Description: $description');
                    print('Latitude: ${widget.locationData?.latitude}');
                    print('Longitude: ${widget.locationData?.longitude}');
                    print(
                        'Accelerometer Values: ${widget.accelerometerValues}');
                    print('Gyroscope Values: ${widget.gyroscopeValues}');
                    print('Magnetometer Values: ${widget.magnetometerValues}');
                    print('Created date: $lastModified');

                    // Create a map of the image metadata
                    final imageMetadata = <String, dynamic>{
                      'datetime': lastModified,
                      'latitude': widget.locationData?.latitude,
                      'longitude': widget.locationData?.longitude,
                      'gyroscope': widget.gyroscopeValues,
                    };

                    // Get a reference to the Firestore collection where the metadata will be stored
                    CollectionReference images =
                        FirebaseFirestore.instance.collection('1');

                    // Add the metadata to the collection
                    images.add(imageMetadata);

                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
