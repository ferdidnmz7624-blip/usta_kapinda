import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'mode_router_page.dart';
import 'phone_otp_dialog.dart';
import '../services/user_service.dart';

class LoginOtpPage extends StatefulWidget {
  const LoginOtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.phoneLogin,
    this.phone,
    this.onAuthenticated,
  });

  final String email;
  final String password;
  final bool phoneLogin;
  final String? phone;
  final Future<void> Function(UserCredential credential)? onAuthenticated;

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  final codeController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  Future<void> _begin() async {
    if (widget.phoneLogin) {
      try {
        final verified = await showPhoneOtpDialog(
          context,
          phone: widget.phone!,
        );
        if (!mounted) return;
        if (verified == null) {
          Navigator.pop(context);
          return;
        }
        final credential = await FirebaseAuth.instance.signInWithCredential(
          verified.credential,
        );
        if (credential.user?.email?.toLowerCase() !=
            widget.email.toLowerCase()) {
          await FirebaseAuth.instance.signOut();
          throw FirebaseAuthException(
            code: 'user-mismatch',
            message: 'Bu telefon başka bir hesaba bağlı.',
          );
        }
        if (!mounted) return;
        await _finish(credential);
      } on FirebaseAuthException catch (exception) {
        if (!mounted) return;
        setState(() {
          error = exception.code == 'user-mismatch'
              ? 'Bu telefon henüz hesaba bağlanmamış. E-posta ile giriş yapın.'
              : exception.message ?? 'Telefon doğrulanamadı.';
        });
      }
      return;
    }
    final response = await http.post(
      Uri.parse(
        'https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/sendVerificationCodeEmail',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'purpose': 'login'}),
    );
    if (!mounted) return;
    if (response.statusCode != 200) {
      setState(() => error = 'Doğrulama kodu gönderilemedi.');
    }
  }

  Future<void> _verifyEmail() async {
    if (codeController.text.trim().length != 6) {
      setState(() => error = '6 haneli kodu girin.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    final response = await http.post(
      Uri.parse(
        'https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/verifyVerificationCode',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'code': codeController.text.trim(),
        'purpose': 'login',
      }),
    );
    final data = response.statusCode == 200
        ? Map<String, dynamic>.from(jsonDecode(response.body))
        : <String, dynamic>{};
    if (!mounted) return;
    if (data['success'] == true) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      if (!mounted) return;
      await _finish(credential);
    } else {
      setState(() {
        loading = false;
        error = data['expired'] == true ? 'Kodun süresi doldu.' : 'Kod yanlış.';
      });
    }
  }

  Future<void> _finish(UserCredential credential) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      unawaited(
        FirebaseMessaging.instance.getToken().then((token) async {
          if (token != null) await UserService().saveFcmToken(uid, token);
        }),
      );
    }
    if (widget.onAuthenticated != null) {
      try {
        await widget.onAuthenticated!(credential);
      } on StateError catch (exception) {
        if (mounted) {
          setState(() {
            loading = false;
            error = exception.message.toString();
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            loading = false;
            error = 'Hesap bağlanamadı. Lütfen tekrar deneyin.';
          });
        }
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ModeRouterPage()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş doğrulama')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.phoneLogin
                  ? Icons.sms_outlined
                  : Icons.mark_email_read_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              widget.phoneLogin
                  ? 'Telefon doğrulaması tamamlanıyor.'
                  : '${widget.email} adresine gönderilen kodu girin.',
              textAlign: TextAlign.center,
            ),
            if (!widget.phoneLogin) ...[
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Doğrulama kodu',
                  errorText: error,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : _verifyEmail,
                  child: Text(loading ? 'Doğrulanıyor…' : 'Giriş yap'),
                ),
              ),
              TextButton(
                onPressed: _begin,
                child: const Text('Kodu yeniden gönder'),
              ),
            ] else if (error != null) ...[
              const SizedBox(height: 20),
              Text(error!, style: const TextStyle(color: Colors.red)),
              TextButton(onPressed: _begin, child: const Text('Tekrar dene')),
            ] else
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
