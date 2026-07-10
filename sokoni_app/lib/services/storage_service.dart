import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Inashughulikia kupakia picha za biashara kwenye Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Pakia picha moja, rudisha download URL
  Future<String> uploadBusinessImage(File file, String businessId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child('businesses/$businessId/$fileName');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Pakia picha nyingi kwa wakati mmoja
  Future<List<String>> uploadMultipleImages(
      List<File> files, String businessId) async {
    final List<String> urls = [];
    for (final file in files) {
      final url = await uploadBusinessImage(file, businessId);
      urls.add(url);
    }
    return urls;
  }
}
