// AUTO-GENERATED — run: flutterfire configure
// Replace these values with your real Firebase project config

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (Platform.operatingSystem) {
      case 'android': return android;
      case 'ios': return ios;
      default: throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.appspot.com',
    iosBundleId: 'com.jamiitek.sokoni',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'sokoni-dc60f',
    storageBucket: 'sokoni-dc60f.appspot.com',
  );
}
