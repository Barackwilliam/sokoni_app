import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

/// Image uploads via Cloudinary (unsigned upload preset).
/// No billing required — free tier covers an MVP comfortably.
/// Works on Android, iOS AND web (bytes-based upload).
///
/// Setup (one time, ~3 minutes):
/// 1. Create a free account at cloudinary.com
/// 2. Dashboard -> copy your "Cloud name"
/// 3. Settings -> Upload -> Upload presets -> Add upload preset
///    - Signing Mode: Unsigned
///    - (Optional) Folder: sokoni
/// 4. Put both values in CloudinaryConfig (lib/utils/constants.dart)
class StorageService {
  Future<String> uploadBusinessImage(XFile file, String businessId) async {
    final bytes = await file.readAsBytes();
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = 'sokoni/businesses/$businessId'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name.isNotEmpty ? file.name : 'photo.jpg',
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      String message = 'Image upload failed (${response.statusCode})';
      try {
        final err = jsonDecode(body);
        if (err is Map && err['error']?['message'] != null) {
          message = 'Image upload failed: ${err['error']['message']}';
        }
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  Future<List<String>> uploadMultipleImages(
      List<XFile> files, String businessId) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await uploadBusinessImage(f, businessId));
    }
    return urls;
  }
}
