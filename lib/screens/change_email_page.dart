import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;

  Future<void> changeEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      setState(() => loading = true);

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.emailVerificationSent,
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context)!.somethingWentWrong,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.changeEmail,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newEmail,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.currentPassword,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : changeEmail,
                child: Text(
                  loading
                      ? AppLocalizations.of(context)!.sending
                      : AppLocalizations.of(context)!.updateEmail,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}