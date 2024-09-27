import 'package:flutter/material.dart';
import "package:tflite/tflite.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'tts.dart';

class ColorRecognition extends StatefulWidget {
  @override
  _ColorRecognitionState createState() => _ColorRecognitionState();
}

class _ColorRecognitionState extends State<ColorRecognition> {
  File? _image; // Make _image nullable
  List? _outputs; // Make _outputs nullable
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    speak('Click anywhere to open the camera and take a photo');
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Color Recognition',
          style: TextStyle(
            // fontFamily: 'nerko',
            fontSize: 30,
            color: Colors.red,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Expanded(
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Click anywhere to open the Camera',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      // fontFamily: 'nerko',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
                          child: Column(
                            children: [
                              Image.file(_image!),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "This seems to be ${_outputs![0]["label"].toString().substring(2)} color",
                                style: TextStyle(
                                  color: Colors.red,
                                  // fontFamily: 'nerko',
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera); // Update method
    if (pickedFile == null) return; // Check if the pickedFile is null
    setState(() {
      _loading = true;
      _image = File(pickedFile.path); // Use pickedFile.path
    });
    classifyImage(_image!); // Pass the image to classifyImage
  }

  Future<void> classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output; // Store the output
    });
    if (_outputs != null) {
      speak("This seems to be ${_outputs![0]["label"].toString().substring(2)} color. Click anywhere to start again.");
    }
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      // model: "assets/model_unquant2.tflite",
      // labels: "assets/labels2.txt",
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true, 
      useGpuDelegate: false 
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
