import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/google_auth_service.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';
import 'mode_router_page.dart';
import 'login_otp_page.dart';

class ExistingAccountLoginPage extends StatefulWidget {
  final String accountType;

  const ExistingAccountLoginPage({super.key, required this.accountType});

  @override
  State<ExistingAccountLoginPage> createState() =>
      _ExistingAccountLoginPageState();
}

class _ExistingAccountLoginPageState extends State<ExistingAccountLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool hidePassword = true;
  bool _isLoading = false;
  String? _sourceUid;
  String? _sourceIdToken;
  UserModel? _sourceUser;

  Future<bool> _prepareSourceAccount() async {
    if (_sourceUid != null && _sourceUser != null) return true;

    final signedInUser = _auth.currentUser;
    if (signedInUser == null) return false;

    final sourceUser = await _userService.getUser(signedInUser.uid);
    if (sourceUser == null) return false;

    _sourceUid = signedInUser.uid;
    _sourceUser = sourceUser;
    _sourceIdToken = await signedInUser.getIdToken();
    return true;
  }

  Future<void> _linkSignedInAccount(UserCredential result) async {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = _sourceUser;
    final linkedUid = result.user?.uid;

    if (currentUser == null || linkedUid == null || _sourceIdToken == null) {
      throw StateError(l10n.loginFailed);
    }

    if (_sourceUid == linkedUid) {
      throw StateError('Aynı hesap kendi kendisiyle bağlanamaz.');
    }

    final linkedUser = await _userService.getUser(linkedUid);
    if (linkedUser == null) {
      throw StateError(l10n.userInfoNotFound);
    }

    if (linkedUser.accountType != widget.accountType) {
      final targetName = widget.accountType == 'craftsman' ? 'usta' : 'müşteri';
      throw StateError('Seçilen hesap bir $targetName hesabı değil.');
    }

    await _userService.linkAccounts(sourceIdToken: _sourceIdToken!);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ModeRouterPage()),
      (route) => false,
    );
  }

  Future<void> loginAndLinkAccount() async {
    final l10n = AppLocalizations.of(context)!;
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginEmailOrPhoneRequired)));
      return;
    }

    try {
      setState(() => _isLoading = true);
      if (!await _prepareSourceAccount()) {
        throw StateError(l10n.loginFailed);
      }

      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Şifreyi doğruladıktan sonra da ana girişteki gibi e-posta OTP'si
      // zorunludur. Böylece ikinci hesabı bağlama ekranı OTP'yi atlayamaz.
      await _auth.signOut();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginOtpPage(
            email: emailController.text.trim(),
            password: passwordController.text,
            phoneLogin: false,
            onAuthenticated: _linkSignedInAccount,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? l10n.loginFailed)));
      }
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loginFailed)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> loginWithGoogleAndLinkAccount() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() => _isLoading = true);
      if (!await _prepareSourceAccount()) {
        throw StateError(l10n.loginFailed);
      }

      await _auth.signOut();
      final result = await GoogleAuthService().signInWithGoogle(
        createProfileIfMissing: false,
      );
      if (result == null) return;
      await _linkSignedInAccount(result);
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.loginFailed)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      appBar: AppBar(title: Text(l10n.existingAccountLogin)),
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
                    hidePassword ? Icons.visibility_off : Icons.visibility,
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : loginWithGoogleAndLinkAccount,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google ile giriş yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
