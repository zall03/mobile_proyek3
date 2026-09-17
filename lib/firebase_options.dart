import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// ============================================================================
// KONFIGURASI FIREBASE
// ----------------------------------------------------------------------------
// Isi nilai di bawah dari Firebase Console:
//   Buka https://console.firebase.google.com > Project (dapur-cerdas)
//   > Project settings > Your apps.
// Cara termudah: setelah project dibuat, jalankan:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<project-id>
// Perintah itu akan menimpa file ini dengan nilai yang benar otomatis.
// ============================================================================
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak didukung untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9JMSZ-W3ts-Ry3XXJ4eqlPl2S1lEnsKM',
    appId: '1:315970193485:web:83876469251ac2ac15f404',
    messagingSenderId: '315970193485',
    projectId: 'dapur-cerdas-e84bc',
    authDomain: 'dapur-cerdas-e84bc.firebaseapp.com',
    storageBucket: 'dapur-cerdas-e84bc.firebasestorage.app',
    measurementId: 'G-NNQME2T027',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWXSDlZVgJQsnDTryFIQ2eepqU4DTA4PM',
    appId: '1:315970193485:android:b0fc94949bb8c46315f404',
    messagingSenderId: '315970193485',
    projectId: 'dapur-cerdas-e84bc',
    storageBucket: 'dapur-cerdas-e84bc.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'GANTI_API_KEY_IOS',
    appId: 'GANTI_APP_ID_IOS',
    messagingSenderId: 'GANTI_SENDER_ID',
    projectId: 'GANTI_PROJECT_ID',
    storageBucket: 'GANTI_PROJECT_ID.appspot.com',
  );
}
