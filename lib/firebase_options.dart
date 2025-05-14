import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY']!,
        appId: dotenv.env['FIREBASE_WEB_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID']!,
        authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN']!,
        storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET']!,
        measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
          appId: dotenv.env['FIREBASE_ANDROID_APP_ID']!,
          messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET']!,
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }
}
