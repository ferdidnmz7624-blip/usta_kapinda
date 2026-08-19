import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../generated/app_localizations.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;

  const NewPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();
  final passwordAgainController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool loading = false;

  @override
  void dispose() {
    passwordController.dispose();
    passwordAgainController.dispose();
    super.dispose();
  }

  Future<void> savePassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (passwordController.text.isEmpty ||
        passwordAgainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillAllFields),
        ),
      );
      return;
    }

    if (passwordController.text !=
        passwordAgainController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/resetPasswordWithCode",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": widget.email,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception(l10n.passwordUpdateFailed);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordChangedSuccessfully),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/login",
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? l10n.somethingWentWrong),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newPassword),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: obscure1,
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure1
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure1 = !obscure1;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordAgainController,
              obscureText: obscure2,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure2
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure2 = !obscure2;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : savePassword,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                  l10n.updatePassword,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}