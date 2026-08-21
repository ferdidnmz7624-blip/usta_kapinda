import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import '../generated/app_localizations.dart';
import 'mode_router_page.dart';

class ExistingAccountLoginPage extends StatefulWidget {
  final String accountType;

  const ExistingAccountLoginPage({
    super.key,
    required this.accountType,
  });

  @override
  State<ExistingAccountLoginPage> createState() =>
      _ExistingAccountLoginPageState();
}

class _ExistingAccountLoginPageState
    extends State<ExistingAccountLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool hidePassword = true;
  bool _isLoading = false;

  Future<void> loginAndLinkAccount() async {
    final signedInUser = _auth.currentUser;
    if (signedInUser == null) {
      _showLoginError();
      return;
    }

    final currentUid = signedInUser.uid;
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() => _isLoading = true);
      await _auth.signOut();

      final result = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final linkedUid = result.user!.uid;

      final currentUser =
      await _userService.getUser(currentUid);

      final linkedUser =
      await _userService.getUser(linkedUid);

      if (currentUser == null || linkedUser == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.userInfoNotFound),
          ),
        );
        return;
      }

      if (widget.accountType == "craftsman") {
        await _userService.updateLinkedAccounts(
          uid: currentUid,
          linkedCraftsmanUid: linkedUid,
          linkedCraftsmanEmail: linkedUser.email,
        );

        await _userService.updateLinkedAccounts(
          uid: linkedUid,
          linkedCustomerUid: currentUid,
          linkedCustomerEmail: currentUser.email,
        );
      } else {
        await _userService.updateLinkedAccounts(
          uid: currentUid,
          linkedCustomerUid: linkedUid,
          linkedCustomerEmail: linkedUser.email,
        );

        await _userService.updateLinkedAccounts(
          uid: linkedUid,
          linkedCraftsmanUid: currentUid,
          linkedCraftsmanEmail: currentUser.email,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ModeRouterPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              e.message ?? l10n.loginFailed
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginFailed)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.existingAccountLogin),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "E-posta",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: "Şifre",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Şifremi Unuttum"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginAndLinkAccount,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Giriş Yap"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
