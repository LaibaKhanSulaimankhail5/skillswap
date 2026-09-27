import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses a picked image and converts it to a Base64 string
/// so it can be stored directly inside a Firestore document.
class ImageService {
  /// Compresses the image to keep it well under Firestore's 1MB document limit.
  Future<String> imageToBase64(File imageFile) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 40,
      minWidth: 400,
      minHeight: 400,
    );

    if (compressedBytes == null) {
      throw Exception('Could not process the selected image.');
    }
    return base64Encode(compressedBytes);
  }
}
