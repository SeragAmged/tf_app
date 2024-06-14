import 'dart:async';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:tf_app/camera_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dynamic cameras = await availableCameras();


  runApp(MyApp(cameras));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  dynamic cameras;
  MyApp(this.cameras, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CameraScreen(cameras),
    );
  }
}