import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class FirebaseMLApi {
  static Future<String> recogniseText(File? imageFile) async {
    // Now the imageFile can be null
    if (imageFile == null) {
      return 'No selected image';
    }

    final inputImage = InputImage.fromFile(imageFile);
    // final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // Use the correct instance

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      final text = extractText(recognizedText);
      return text.isEmpty ? 'No text found in the image' : text;
    } catch (error) {
      return 'Error processing image: ${error.toString()}';
    } finally {
      // Always close the recognizer
      await textRecognizer.close();
    }
  }

  static String extractText(RecognizedText recognizedText) {
    StringBuffer textBuffer = StringBuffer();

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        textBuffer.writeln(line.text); // Use StringBuffer for better performance
      }
    }

    return textBuffer.toString();
  }
}
