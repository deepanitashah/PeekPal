import 'dart:io';
import 'api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peekpal/tts.dart';

class Expiry extends StatefulWidget {
  const Expiry({Key? key}) : super(key: key); // Key nullable due to null safety

  @override
  _ExpiryState createState() => _ExpiryState();
}

class _ExpiryState extends State<Expiry> {
  String _text = '';
  File? image; // Image is nullable
  bool _loading = false;
  String out = '';

  static DateTime now = DateTime.now();
  DateTime date = DateTime(now.year, now.month, now.day);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Expiry Date',
            style: TextStyle(
              fontFamily: 'nerko',
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
                    image == null
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
                                          fontFamily: 'nerko'),
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
                                Image.file(image!),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '$out\nToday\'s Date: ${date.day} ${date.month} ${date.year}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'nerko',
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

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera); // Updated method
    if (pickedFile != null) {
      setImage(File(pickedFile.path));
      scanText(); // Start scanning the text after picking the image
    }
  }

  Future<void> scanText() async {
    setState(() {
      _loading = true; // Show the loading spinner
    });

    final text = await FirebaseMLApi.recogniseText(image!);
    setState(() {
      _text = text;
      _loading = false; // Hide the loading spinner
    });

    if (_text.isNotEmpty) {
      // Handle text recognition results as you have done in your existing code
      processExpiryText(_text);
    }
  }

  void processExpiryText(String recognisedText) {
    // The same logic you're using to process the expiry text
    if (recognisedText.contains('Exp Date')) {
      int index = recognisedText.indexOf('Exp');
      var ans = recognisedText.substring(index, index + 17);
      out = ans;
      speak(ans + " And Today's Date ${date.day} ${date.month} ${date.year}");
    }
    // Add other text conditions here as you already have them in your code.
    else {
      speak('No expiry date found. Please try again.');
      out = 'No expiry date found. Please try again.';
    }
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }
}
