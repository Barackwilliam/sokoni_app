// Firebase configuration for Sokoni (project: sokoni-dc60f).
//
// ANDROID values below are the real ones (from google-services.json).
// iOS / WEB still need real API keys — run once on your machine:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// and this file will be regenerated with all platforms filled in.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not configured for this platform. '
            'Run `flutterfire configure`.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZX0KPygwvGM6W702k0SneGmpLtl6g6t0',
    appId: '1:125831217352:android:3d91b7bc271c6db065e5fd',
    messagingSenderId: '125831217352',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.firebasestorage.app',
  );

  // Placeholders — regenerate with `flutterfire configure` before iOS/web use.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:125831217352:ios:5af550a36061b38365e5fd',
    messagingSenderId: '125831217352',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.firebasestorage.app',
    iosBundleId: 'com.jamiitek.sokoni',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:125831217352:web:88f1f9f7f1396ddb65e5fd',
    messagingSenderId: '125831217352',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.firebasestorage.app',
  );
}
