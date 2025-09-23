import 'package:image_picker/image_picker.dart';

abstract class OcrService {
  Future<String> recognizeText(XFile image);
}