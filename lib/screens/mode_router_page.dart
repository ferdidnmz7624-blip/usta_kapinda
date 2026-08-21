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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
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
