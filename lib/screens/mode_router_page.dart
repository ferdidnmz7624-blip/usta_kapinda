import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'craftsman_main_page.dart';
import 'customer_main_page.dart';
import 'login_page.dart';

class ModeRouterPage extends StatelessWidget {
  const ModeRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return const LoginPage();
    }

    return StreamBuilder<UserModel?>(
      stream: UserService().streamUser(firebaseUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _ProfileUnavailable(
            message:
                'Profiliniz yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.',
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Yeni kayıtta Auth oturumu, Firestore profilinden önce hazır olur.
          // Profil yazımı başarısız kalırsa kullanıcı ekranda sonsuza dek beklemez.
          return const _ProfileUnavailable(
            message:
                'Profiliniz hazırlanıyor. Bu ekran uzun sürerse tekrar giriş yapın.',
          );
        }

        final user = snapshot.data!;

        if (user.activeMode == "craftsman") {
          return const CraftsmanMainPage();
        }

        return const CustomerMainPage();
      },
    );
  }
}

class _ProfileUnavailable extends StatelessWidget {
  final String message;

  const _ProfileUnavailable({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Çıkış yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
