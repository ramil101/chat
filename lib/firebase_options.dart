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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCEk-resoEUo2PK-pKWGETvMB2sup-sDhY',
    appId: '1:99572898975:web:59cc18771c2f8767e556aa',
    messagingSenderId: '99572898975',
    projectId: 'chat-app-c52dc',
    authDomain: 'chat-app-c52dc.firebaseapp.com',
    storageBucket: 'chat-app-c52dc.firebasestorage.app',
    measurementId: 'G-KGD71GEHVQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAc51XRHj0WClGTMF11IMbs7W-htnMnGVQ',
    appId: '1:99572898975:android:a37b56bab5069096e556aa',
    messagingSenderId: '99572898975',
    projectId: 'chat-app-c52dc',
    storageBucket: 'chat-app-c52dc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBr9fWnC4EAljc-qu_ZH2bDVhYqFT6aCgE',
    appId: '1:99572898975:ios:0ee1b815660f30d5e556aa',
    messagingSenderId: '99572898975',
    projectId: 'chat-app-c52dc',
    storageBucket: 'chat-app-c52dc.firebasestorage.app',
    iosBundleId: 'com.example.chat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBr9fWnC4EAljc-qu_ZH2bDVhYqFT6aCgE',
    appId: '1:99572898975:ios:0ee1b815660f30d5e556aa',
    messagingSenderId: '99572898975',
    projectId: 'chat-app-c52dc',
    storageBucket: 'chat-app-c52dc.firebasestorage.app',
    iosBundleId: 'com.example.chat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCEk-resoEUo2PK-pKWGETvMB2sup-sDhY',
    appId: '1:99572898975:web:b838742b43aee5f0e556aa',
    messagingSenderId: '99572898975',
    projectId: 'chat-app-c52dc',
    authDomain: 'chat-app-c52dc.firebaseapp.com',
    storageBucket: 'chat-app-c52dc.firebasestorage.app',
    measurementId: 'G-E11TQ4ZBY7',
  );
}
