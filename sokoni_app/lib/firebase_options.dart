// File hili linatakiwa li-generate automatically na FlutterFire CLI.
// USIBADILI FILE HILI BY HAND - badala yake fanya:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Hii itaunganisha app na Firebase project yako halisi na ku-overwrite
// file hili na values sahihi (apiKey, appId, projectId, n.k) kwa
// Android na iOS. Values zilizopo hapa chini ni PLACEHOLDER tu na
// HAZITAFANYA KAZI mpaka uzibadilishe.

import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (Platform.operatingSystem) {
      case 'android':
        return android;
      case 'ios':
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions haijawekewa platform hii bado.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_YOUR_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
    iosBundleId: 'com.jamiitek.sokoni',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
  );
}
