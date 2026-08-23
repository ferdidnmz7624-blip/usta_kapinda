import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(
      length,
          (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      final appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = appleCredential.identityToken;

      if (identityToken == null) {
        throw Exception('Apple kimlik doğrulama tokenı alınamadı.');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
      await _auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user != null) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final snapshot = await doc.get();

        if (!snapshot.exists) {
          final firstName = appleCredential.givenName ?? '';
          final lastName = appleCredential.familyName ?? '';

          await doc.set({
            'uid': user.uid,
            'firstName': firstName,
            'lastName': lastName,
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'profilePhoto': '',
            'accountType': 'customer',
            'activeMode': 'customer',
            'customerProfile': true,
            'craftsmanProfile': false,
            'linkedCustomerUid': '',
            'linkedCraftsmanUid': '',
            'linkedCustomerEmail': '',
            'linkedCraftsmanEmail': '',
            'rating': 5.0,
            'completedJobs': 0,
            'tokens': 0,
            'isFrozen': false,
            'isDeleting': false,
            'experience': 0,
            'professions': <String>[],
            'about': '',
            'city': '',
            'district': '',
            'neighborhood': '',
            'address': '',
            'isOnline': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
