import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/user_service.dart';
import '../services/google_auth_service.dart';
import '../services/apple_auth_service.dart';
import 'mode_router_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verification_code_page.dart';
import 'login_otp_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../generated/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final String? initialEmail;

  const LoginPage({super.key, this.initialEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    loadLanguage();

    if (widget.initialEmail != null) {
      emailController.text = widget.initialEmail!;
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleAuthService _googleAuth = GoogleAuthService();
  final AppleAuthService _appleAuth = AppleAuthService();
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = true;
  bool emailError = false;
  bool passwordError = false;

  String selectedLanguage = "TR";
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedLanguage = prefs.getString("language") ?? "TR";
    });
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("language", language);
  }

  String? emailErrorText;
  String? passwordErrorText;
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final l10n = AppLocalizations.of(context)!;
    var mustClearPreOtpSession = false;
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginEmailOrPhoneRequired)));
      return;
    }

    try {
      setState(() {
        isLoading = true;
        emailError = false;
        passwordError = false;
        emailErrorText = null;
        passwordErrorText = null;
      });

      String loginValue = emailController.text.trim();
      String email = loginValue;
      final isPhoneLogin = !loginValue.contains("@");
      String? normalizedPhone;

      if (isPhoneLogin) {
        String phone = loginValue
            .replaceAll(" ", "")
            .replaceAll("-", "")
            .replaceAll("(", "")
            .replaceAll(")", "");

        if (phone.startsWith("0")) {
          phone = phone.substring(1);
        }
        normalizedPhone = phone;

        final callable = FirebaseFunctions.instanceFor(
          region: "europe-west1",
        ).httpsCallable("getEmailByPhone");

        final response = await callable.call({"phone": phone});

        final data = Map<String, dynamic>.from(response.data);

        if (data["success"] != true) {
          setState(() {
            emailError = true;
            emailErrorText = l10n.phoneAccountNotFound;
          });

          return;
        }

        email = data["email"];
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text,
      );
      mustClearPreOtpSession = true;

      final appUser = await UserService().getUser(_auth.currentUser!.uid);

      if (appUser == null) {
        await _auth.signOut();
        mustClearPreOtpSession = false;
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.userNotFound)));
        return;
      }

      // Apple incelemesi için tanımlanmış geçici test hesabı, e-posta OTP'si
      // beklemeden uygulamayı inceleyebilsin. Bu alan yalnızca güvenilir
      // yönetici tarafından Firestore'da atanır; istemci kuralları kullanıcı
      // tarafından eklenmesine veya değiştirilmesine izin vermez.
      if (appUser.appReviewOtpBypass) {
        mustClearPreOtpSession = false;
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ModeRouterPage()),
          (_) => false,
        );
        return;
      }

      // Parola doğru olsa bile OTP bitmeden yetkili Firebase oturumu bırakma.
      await _auth.signOut();
      mustClearPreOtpSession = false;

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginOtpPage(
            email: email,
            password: passwordController.text,
            phoneLogin: isPhoneLogin,
            phone: normalizedPhone,
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        emailError = true;
        emailErrorText = e.message ?? l10n.phoneVerificationServiceUnavailable;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        emailError = false;
        passwordError = false;
        emailErrorText = null;
        passwordErrorText = null;

        switch (e.code) {
          case "wrong-password":
            passwordError = true;
            passwordErrorText = l10n.wrongPassword;
            break;

          case "user-not-found":
            emailError = true;
            emailErrorText = l10n.emailAccountNotFound;
            break;

          case "invalid-email":
            emailError = true;
            emailErrorText = emailErrorText = l10n.invalidEmailAddress;
            break;

          case "invalid-credential":
            passwordError = true;
            passwordErrorText = l10n.invalidEmailOrPhonePassword;
            break;

          case "too-many-requests":
            passwordError = true;
            passwordErrorText = l10n.tooManyLoginAttempts;
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? l10n.loginFailed)),
            );
        }
      });
    } finally {
      // OTP sayfasına geçilemeden oluşan her hatada oturum açık kalmasın.
      if (mustClearPreOtpSession) {
        await _auth.signOut();
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _saveFcmTokenInBackground(String uid) {
    unawaited(
      FirebaseMessaging.instance
          .getToken()
          .then((token) async {
            if (token != null) {
              await UserService().saveFcmToken(uid, token);
            }
          })
          .catchError((error) {
            debugPrint("Bildirim kaydı ertelendi: $error");
          }),
    );
  }

  Future<void> resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterEmailFirst)));
      return;
    }

    final response = await http.post(
      Uri.parse(
        "https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/sendVerificationCodeEmail",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "purpose": "password_reset",
      }),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.codeCouldNotBeSent)));
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodePage(
          firstName: "",
          lastName: "",
          phone: "",
          password: "",
          accountType: "",
          city: "",
          district: "",
          neighborhood: "",
          address: "",
          professions: const [],
          experience: 0,
          about: "",
          email: emailController.text.trim(),
          isResetPassword: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  tooltip: l10n.selectLanguage,
                  onSelected: (value) async {
                    if (value == null) return;

                    await context.read<LanguageProvider>().changeLanguage(
                      value,
                    );

                    setState(() {
                      selectedLanguage = value.toUpperCase();
                    });

                    await saveLanguage(selectedLanguage);
                  },

                  itemBuilder: (context) => const [
                    PopupMenuItem(value: "tr", child: Text("🇹🇷 Türkçe")),

                    PopupMenuItem(value: "en", child: Text("🇺🇸 English")),

                    PopupMenuItem(value: "de", child: Text("🇩🇪 Deutsch")),

                    PopupMenuItem(value: "ru", child: Text("🇷🇺 Русский")),

                    PopupMenuItem(value: "ar", child: Text("🇸🇦 العربية")),
                  ],

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffdddddd)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, size: 18),

                        SizedBox(width: 6),

                        Text(
                          selectedLanguage,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 30),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(.35),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                AppLocalizations.of(context)!.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                AppLocalizations.of(context)!.findCraftsman,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(.7),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: emailController,
                  onChanged: (_) {
                    if (emailError) {
                      setState(() {
                        emailError = false;
                        emailErrorText = null;
                      });
                    }
                  },
                  focusNode: emailFocus,
                  // Hesap türü değiştirirken hedef e-posta otomatik gelir;
                  // kullanıcı isterse farklı e-posta/telefon yazabilmelidir.
                  readOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError ? emailErrorText : null,
                    hintText: AppLocalizations.of(context)!.emailOrPhone,
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xffdddddd)),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: passwordFocus,
                  controller: passwordController,
                  onChanged: (_) {
                    if (passwordError) {
                      setState(() {
                        passwordError = false;
                        passwordErrorText = null;
                      });
                    }
                  },
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    errorText: passwordError ? passwordErrorText : null,
                    hintText: AppLocalizations.of(context)!.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xffdddddd)),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (v) {
                          setState(() {
                            rememberMe = v ?? true;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.rememberMe),
                    ],
                  ),
                  TextButton(
                    onPressed: resetPassword,
                    child: Text(AppLocalizations.of(context)!.forgotPassword),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          AppLocalizations.of(context)!.login,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.or),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final credential = await _googleAuth.signInWithGoogle();

                      if (credential == null) return;
                      _saveFcmTokenInBackground(
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                      if (!mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const ModeRouterPage(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/google.svg",
                    width: 24,
                    height: 24,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.loginWithGoogle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Color(0xffdddddd)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final credential = await _appleAuth.signInWithApple();

                      if (credential == null) return;
                      _saveFcmTokenInBackground(
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                      if (!mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const ModeRouterPage(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: const Icon(Icons.apple, size: 28),
                  label: Text(
                    AppLocalizations.of(context)!.loginWithApple,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: const BorderSide(color: Color(0xffdddddd)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.noAccount,
                    style: const TextStyle(fontSize: 16),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      AppLocalizations.of(context)!.createAccount,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
