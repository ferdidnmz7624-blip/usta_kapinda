import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import 'existing_account_login_page.dart';
import '../generated/app_localizations.dart';

class CompleteSecondProfilePage extends StatelessWidget {
  final String accountType;

  const CompleteSecondProfilePage({
    super.key,
    required this.accountType,
  });

  void completeProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPage(
          accountType: accountType,
          linkedUid: FirebaseAuth.instance.currentUser?.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          accountType == "craftsman"
              ? AppLocalizations.of(context)!.createCraftsmanProfile
              : AppLocalizations.of(context)!.createCustomerProfile,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => completeProfile(context),
              child: Text(
                AppLocalizations.of(context)!.createProfile,
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExistingAccountLoginPage(
                      accountType: accountType,
                    ),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.alreadyHaveAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}