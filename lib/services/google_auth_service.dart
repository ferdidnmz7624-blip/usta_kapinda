import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '857244787940-voisdb8md8jja2jkpmun6bis8phr8n41.apps.googleusercontent.com',
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      print('GOOGLE ID TOKEN VAR MI: ${googleAuth.idToken != null}');
      print('GOOGLE ACCESS TOKEN VAR MI: ${googleAuth.accessToken != null}');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      print('FIREBASE CREDENTIAL OLUŞTURULUYOR');

      final userCredential =
      await _auth.signInWithCredential(credential);

      print('FIREBASE SIGN IN BAŞARILI');

      final user = userCredential.user;

      if (user != null) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        final snapshot = await doc.get();

        if (!snapshot.exists) {
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
            'wallet': 0.0,
            'rating': 5.0,
            'completedJobs': 0,
            'experience': 0,
            'profession': '',
            'about': '',
            'city': '',
            'district': '',
            'neighborhood': '',
            'address': '',
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
