import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadBusinessImage(File file, String businessId) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child('businesses/$businessId/$name');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<List<String>> uploadMultipleImages(List<File> files, String businessId) async {
    final urls = <String>[];
    for (final f in files) { urls.add(await uploadBusinessImage(f, businessId)); }
    return urls;
  }
}
