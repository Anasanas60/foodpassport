import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:foodpassport/services/ocr_service.dart'; // ← ADD THIS IMPORT

class OcrServiceMobile extends OcrService { // ← CHANGE "implements" to "extends"
  @override
  Future<String> recognizeText(XFile image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text;
  }
}