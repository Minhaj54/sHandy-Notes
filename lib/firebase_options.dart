// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDFOX2VMBeQTdRTr389okEtEmFMYUF1ipU',
    appId: '1:896599817618:web:5c8659c855efb7d363d54b',
    messagingSenderId: '896599817618',
    projectId: 'petmedical-9b723',
    authDomain: 'petmedical-9b723.firebaseapp.com',
    storageBucket: 'petmedical-9b723.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmlRZEKy92yH87hnreNmR58n1KuEUpzCs',
    appId: '1:896599817618:android:dda0d567d8c977c263d54b',
    messagingSenderId: '896599817618',
    projectId: 'petmedical-9b723',
    storageBucket: 'petmedical-9b723.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOHaXeMibCvoQFGIcSG0Ma5dqjRRvKQ8o',
    appId: '1:896599817618:ios:d44adeb3e39ef93063d54b',
    messagingSenderId: '896599817618',
    projectId: 'petmedical-9b723',
    storageBucket: 'petmedical-9b723.appspot.com',
    iosBundleId: 'com.example.notesHub',
  );
}
