import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_app/camera_button.dart';
import 'package:tflite_v2/tflite_v2.dart';

// ignore: must_be_immutable
class CameraScreen extends StatefulWidget {
  dynamic cameras;
  CameraScreen(this.cameras, {super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late CameraImage cameraImage;
  final List<String> imgList = [];
  int imageCount = 0;

  @override
  void initState() {
    super.initState();
    initTensorFlow();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});

      controller.startImageStream((image) {
        imageCount++;
        if (imageCount % 10 == 0) {
          imageCount = 0;
          cameraImage = image;
          objectRecognition();
        }

        // log(DateTime.now().millisecond.toString());
      }).catchError((_) {
        log(_.toString());
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> initTensorFlow() async {
    String? res = await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/labels.txt",
      numThreads: 1, // defaults to 1
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    Tflite.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CameraPreview(controller),
        Positioned(
          top: 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imgList.length,
            itemBuilder: (context, index) => Image.file(
              File(imgList[index]),
              height: 100,
              width: 100,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          child: GestureDetector(
            onTap: () => capture(),
            child: const CameraButton(),
          ),
        ),
      ],
    );
  }

  Future<void> objectRecognition() async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );

    print(recognitions);
  }

  void capture() async {
    final XFile imageFile = await controller.takePicture();
    imgList.add(imageFile.path);
    setState(() {});
    log(imageFile.path);
  }
}
