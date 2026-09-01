import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'new_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'mode_router_page.dart';
import '../generated/app_localizations.dart';

class VerificationCodePage extends StatefulWidget {
  final bool isResetPassword;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final PhoneAuthCredential? phoneCredential;

  final String accountType;
  final String? linkedUid;
  final String? sourceIdToken;

  final String city;
  final String district;
  final String neighborhood;
  final String address;

  final List<String> professions;
  final int experience;
  final String about;
  const VerificationCodePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.phoneCredential,

    required this.accountType,
    this.linkedUid,
    this.sourceIdToken,

    required this.city,
    required this.district,
    required this.neighborhood,
    required this.address,

    required this.professions,
    required this.experience,
    required this.about,
    this.isResetPassword = false,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  int remainingSeconds = 50;
  bool canResend = false;
  bool _isVerifying = false;

  int verificationExpireSeconds = 120;
  Future<void> verifyCode() async {
    if (_isVerifying) return;

    final l10n = AppLocalizations.of(context)!;

    final code = controllers.map((e) => e.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterSixDigitCode)));
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse(
          "https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/verifyVerificationCode",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "code": code,
          "purpose": widget.isResetPassword ? "password_reset" : "registration",
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Doğrulama servisine ulaşılamadı.');
      }

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        if (!mounted) return;
        if (widget.isResetPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NewPasswordPage(
                email: widget.email,
                resetToken: data["resetToken"] as String,
              ),
            ),
          );
          return;
        }
        final auth = FirebaseAuth.instance;
        final userService = UserService();

        final result = await auth.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );
        final user = UserModel(
          uid: result.user!.uid,
          accountType: widget.accountType,

          customerProfile: widget.accountType == "customer",
          craftsmanProfile: widget.accountType == "craftsman",
          activeMode: widget.accountType,

          linkedCustomerUid: widget.accountType == "craftsman"
              ? widget.linkedUid ?? ""
              : "",

          linkedCraftsmanUid: widget.accountType == "customer"
              ? widget.linkedUid ?? ""
              : "",

          linkedCustomerEmail: "",
          linkedCraftsmanEmail: "",

          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          phone: widget.phone,

          city: widget.city,
          district: widget.district,
          neighborhood: widget.neighborhood,
          address: widget.address,

          professions: widget.professions,
          experience: widget.experience,
          about: widget.about,

          profilePhoto: "",
          rating: 5,
          completedJobs: 0,
          tokens: 0,
          isFrozen: false,
          isDeleting: false,
          appReviewOtpBypass: false,
          deleteAt: null,
          createdAt: DateTime.now(),
          isOnline: false,
          lastSeen: null,
        );

        if (widget.phoneCredential != null) {
          try {
            await result.user!.linkWithCredential(widget.phoneCredential!);
          } on FirebaseAuthException {
            await result.user!.delete();
            rethrow;
          }
        }
        await userService.saveUser(user);
        // Firestore profili gerçekten erişilebilir olmadan ana ekrana geçme.
        // Böylece yeni kullanıcı ilk açılışta boş/yükleniyor ekranda kalmaz.
        final savedUser = await userService.getUser(result.user!.uid);
        if (savedUser == null) {
          throw StateError('Kullanıcı profili oluşturulamadı.');
        }

        if (widget.sourceIdToken != null && widget.sourceIdToken!.isNotEmpty) {
          await userService.linkAccounts(sourceIdToken: widget.sourceIdToken!);
        }
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ModeRouterPage()),
          (route) => false,
        );

        return;
      } else if (data["expired"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.codeExpired)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidCode)));
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? l10n.registrationFailed)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.registrationFailed)));
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return false;

      if (remainingSeconds == 0) {
        setState(() {
          canResend = true;
        });
        return false;
      }

      setState(() {
        remainingSeconds--;

        if (verificationExpireSeconds > 0) {
          verificationExpireSeconds--;
        }
      });

      return true;
    });
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }

    for (final f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      appBar: AppBar(title: Text(l10n.emailVerification), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(.35),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: 55,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                l10n.emailVerification,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Text(
                l10n.verificationCodeSent(widget.email),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 15),

              Text(
                l10n.checkSpamFolder,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 35),

              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index + 1]);
                        }

                        if (value.isEmpty && index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.verifyCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                canResend
                    ? l10n.requestNewCode
                    : l10n.newCodeInSeconds(remainingSeconds),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              Text(
                l10n.codeValiditySeconds(verificationExpireSeconds),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: canResend
                    ? () async {
                        final response = await http.post(
                          Uri.parse(
                            "https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/sendVerificationCodeEmail",
                          ),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "email": widget.email,
                            "purpose": widget.isResetPassword
                                ? "password_reset"
                                : "registration",
                          }),
                        );

                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.newVerificationCodeSent),
                            ),
                          );

                          setState(() {
                            remainingSeconds = 50;
                            canResend = false;
                          });

                          startTimer();
                        }
                      }
                    : null,
                child: Text(
                  l10n.resendCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
