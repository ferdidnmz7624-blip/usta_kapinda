import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '857244787940-voisdb8md8jja2jkpmun6bis8phr8n41.apps.googleusercontent.com',
  );

  Future<UserCredential?> signInWithGoogle({
    bool createProfileIfMissing = true,
    bool forceAccountPicker = true,
  }) async {
    try {
      // Firebase'den çıkış yapmak Google hesabını yerelde seçili bırakır.
      // Her girişte seçim ekranı isteniyorsa önce sağlayıcı oturumunu temizle.
      if (forceAccountPicker) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          // Sağlayıcıda açık bir hesap yoksa seçim ekranını yine göster.
        }
      }
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final snapshot = await doc.get();

        if (!snapshot.exists && createProfileIfMissing) {
          await doc.set({
            'uid': user.uid,
            'firstName': user.displayName ?? '',
            'lastName': '',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'profilePhoto': user.photoURL ?? '',
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
    try {
      await _googleSignIn.signOut();
    } finally {
      await _auth.signOut();
    }
  }
}
