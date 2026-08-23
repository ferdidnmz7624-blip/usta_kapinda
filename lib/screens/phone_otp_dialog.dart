import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifiedPhone {
  const VerifiedPhone({
    required this.phoneNumber,
    required this.credential,
  });

  final String phoneNumber;
  final PhoneAuthCredential credential;
}

String normalizeTurkishPhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('90') && digits.length == 12) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0') && digits.length == 11) {
    digits = digits.substring(1);
  }
  if (digits.length != 10) {
    throw const FormatException('Geçerli bir telefon numarası girin.');
  }
  return '+90$digits';
}

Future<VerifiedPhone?> showPhoneOtpDialog(
  BuildContext context, {
  required String phone,
}) async {
  final normalizedPhone = normalizeTurkishPhone(phone);
  String? verificationId;
  int? resendToken;
  String? error;
  bool sending = true;
  bool verifying = false;
  int remaining = 50;
  Timer? timer;
  final controller = TextEditingController();

  Future<void> sendCode(StateSetter update, {bool resend = false}) async {
    update(() {
      sending = true;
      error = null;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      forceResendingToken: resend ? resendToken : null,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) {
        if (context.mounted) {
          Navigator.of(context).pop(
            VerifiedPhone(
              phoneNumber: normalizedPhone,
              credential: credential,
            ),
          );
        }
      },
      verificationFailed: (exception) {
        update(() {
          sending = false;
          error = exception.message ?? 'SMS kodu gönderilemedi.';
        });
      },
      codeSent: (id, token) {
        verificationId = id;
        resendToken = token;
        remaining = 50;
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 1), (value) {
          if (remaining <= 0) {
            value.cancel();
          } else {
            update(() => remaining--);
          }
        });
        update(() => sending = false);
      },
      codeAutoRetrievalTimeout: (id) => verificationId = id,
    );
  }

  final result = await showDialog<VerifiedPhone>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, update) {
        if (sending && verificationId == null && timer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sendCode(update);
          });
          timer = Timer(const Duration(days: 1), () {});
        }
        return AlertDialog(
          title: const Text('Telefon doğrulama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$normalizedPhone numarasına gönderilen 6 haneli kodu girin.'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Doğrulama kodu',
                  errorText: error,
                  counterText: '',
                ),
              ),
              if (sending) const LinearProgressIndicator(),
              TextButton(
                onPressed: !sending && remaining == 0
                    ? () => sendCode(update, resend: true)
                    : null,
                child: Text(
                  remaining == 0
                      ? 'Kodu yeniden gönder'
                      : '$remaining saniye sonra yeniden gönder',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: verifying ? null : () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: sending || verifying || verificationId == null
                  ? null
                  : () async {
                      if (controller.text.trim().length != 6) {
                        update(() => error = '6 haneli kodu girin.');
                        return;
                      }
                      update(() {
                        verifying = true;
                        error = null;
                      });
                      final credential = PhoneAuthProvider.credential(
                        verificationId: verificationId!,
                        smsCode: controller.text.trim(),
                      );
                      Navigator.pop(
                        dialogContext,
                        VerifiedPhone(
                          phoneNumber: normalizedPhone,
                          credential: credential,
                        ),
                      );
                    },
              child: Text(verifying ? 'Doğrulanıyor…' : 'Doğrula'),
            ),
          ],
        );
      },
    ),
  );
  timer?.cancel();
  controller.dispose();
  return result;
}
