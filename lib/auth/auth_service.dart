import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Aktif kullanıcı
  User? get currentUser => _auth.currentUser;

  // Giriş Yap
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Kayıt Ol
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Oturum değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';

      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanılıyor.';

      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';

      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';

      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Daha sonra tekrar deneyin.';

      default:
        return e.message ?? 'Bilinmeyen bir hata oluştu.';
    }
  }
}