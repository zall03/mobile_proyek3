import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Mendapatkan Firebase ID token dari akun Google.
  ///
  /// - Web: pakai `signInWithPopup` (menggunakan OAuth client web bawaan
  ///   Firebase, sehingga tidak perlu Web Client ID manual).
  /// - Android/iOS: pakai `google_sign_in` native.
  Future<String> getIdToken() async {
    User? currentUser;

    if (kIsWeb) {
      final userCredential = await _auth.signInWithPopup(
        GoogleAuthProvider(),
      );
      currentUser = userCredential.user;
    } else {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        throw Exception('Anda membatalkan masuk dengan Google');
      }

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      currentUser = userCredential.user;
    }

    if (currentUser == null) {
      throw Exception('Gagal mendapatkan akun dari Firebase');
    }

    final firebaseIdToken = await currentUser.getIdToken();
    if (firebaseIdToken == null) {
      throw Exception('Gagal mendapatkan token verifikasi');
    }

    return firebaseIdToken;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}