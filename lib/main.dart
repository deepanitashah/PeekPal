import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:peekpal/color.dart';
import 'package:peekpal/currency.dart';
import 'package:peekpal/text/expiry.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'tts.dart';
import 'text/recogniser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeekPal',
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech; // Declare it with 'late' for null safety
  bool _isListening = false;
  String _text = 'Touch anywhere and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    speak("What do you want to do?");
    _speech = stt.SpeechToText(); // Initialize the instance here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Accuracy: ${(_confidence * 100.0).toStringAsFixed(1)}%',
            style: TextStyle(
              fontFamily: 'nerko',
              color: Colors.red,
              fontSize: 30,
            ),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: () {
          _listen();
        },
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center, // Center the text in the middle of the screen
          child: Text(
            _text,
            style: const TextStyle(
              fontFamily: 'nerko',
              fontSize: 32.0,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }

            // Navigate to different screens based on spoken words
            if (_text.contains('currency')) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CurrencyRecognition()));
            } else if (_text.contains('color') || _text.contains('colour')) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ColorRecognition()));
            } else if (_text.contains('text') || _text.contains('read')) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TextRecognitionWidget()));
            } else if (_text.contains('expiry')) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Expiry()));
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}

