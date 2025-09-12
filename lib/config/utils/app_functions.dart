import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppFunctions {
  static Future<Position?> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Use Geolocator's permission system instead of permission_handler
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied - stay in app, don't redirect to settings
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied - stay in app, don't redirect to settings
      return null;
    }

    // Permission granted, get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  static Future<File?> uploadFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: backgroundColor ?? Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // static Future<void> loadModel() async {
  //   String? res = await Tflite.loadModel(
  //     model: "assets/pothole_model.tflite",
  //     labels: "assets/labels.txt",
  //   );
  //   print("Model loaded: $res");
  // }
}
