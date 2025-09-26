// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:foodpassport/services/ocr_service.dart';

class OcrServiceWeb extends OcrService {
  Future<void> _loadTesseractJS() async {
    if (js.context.hasProperty('Tesseract')) {
      return; // Already loaded
    }

    final script = html.ScriptElement()
      ..src = 'https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/tesseract.min.js'
      ..async = true;

    final completer = Completer<void>();
    script.onLoad.listen((_) => completer.complete());
    script.onError.listen(
        (_) => completer.completeError('❌ Failed to load Tesseract.js'));

    html.document.head!.append(script);
    await completer.future;
  }

  @override
  Future<String> recognizeText(XFile image) async {
    await _loadTesseractJS();

    final bytes = await image.readAsBytes();
    final base64 = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64';

    try {
      // ✅ Correct way to get worker
      final worker = js.context['Tesseract'].callMethod('createWorker');

      // Initialize worker
      await _callWorkerMethod(worker, 'load');
      await _callWorkerMethod(worker, 'loadLanguage', ['eng']);
      await _callWorkerMethod(worker, 'initialize', ['eng']);

      // OCR recognition step
      final result = await _callWorkerMethod(worker, 'recognize', [dataUrl]);

      // Convert JS object back into Dart-accessible
      final resultJs = js.JsObject.fromBrowserObject(result);
      final text = resultJs['data']['text'] ?? '';

      // Clean up
      await _callWorkerMethod(worker, 'terminate');

      return text.toString();
    } catch (e) {
      return "OCR Error: $e";
    }
  }

  Future<dynamic> _callWorkerMethod(
      js.JsObject worker, String method, [List<dynamic>? args]) async {
    final promise = worker.callMethod(method, args ?? []);
    final completer = Completer<dynamic>();

    promise.callMethod('then', [
      js.allowInterop((value) => completer.complete(value)),
      js.allowInterop((error) => completer.completeError(error.toString())),
    ]);

    return completer.future;
  }
}
