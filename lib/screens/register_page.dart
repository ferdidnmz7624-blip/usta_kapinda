import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../data/cities.dart';
import '../data/districts.dart';
import '../search/search_delegates.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'verification_code_page.dart';
import '../generated/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  final String accountType;
  final String? linkedUid;

  const RegisterPage({
    super.key,
    required this.accountType,
    this.linkedUid,
  });
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
final FirebaseAuth _auth = FirebaseAuth.instance;
final UserService _userService = UserService();

bool isLoading = false;
bool hidePassword = true;
bool hideConfirm = true;
bool kvkk = false;
bool terms = false;
bool privacy = false;

late String accountType;

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final emailController = TextEditingController();
final phoneController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();

final cityController = TextEditingController();
final districtController = TextEditingController();
final neighborhoodController = TextEditingController();
final addressController = TextEditingController();

final professionController = TextEditingController();
final experienceController = TextEditingController();
final aboutController = TextEditingController();
final List<String> selectedProfessions = [];

String? firstNameError;
String? lastNameError;
String? emailError;
String? phoneError;
String? passwordError;
String? confirmPasswordError;
String? neighborhoodError;
String? addressError;
String? experienceError;
String? aboutError;

@override
void initState() {
super.initState();
accountType = widget.accountType;
}

InputDecoration field(
    String hint,
    IconData icon, {
      Widget? suffix,
      String? errorText,
      String? counterText,
    }) {
  final hasError = errorText != null && errorText.isNotEmpty;

  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,

    errorText: errorText,
    counterText: counterText,

    filled: true,
    fillColor: Theme.of(context).cardColor,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 18,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: hasError
          ? const BorderSide(
        color: Colors.red,
        width: 1.5,
      )
          : BorderSide.none,
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: hasError
          ? const BorderSide(
        color: Colors.red,
        width: 2,
      )
          : BorderSide.none,
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.5,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  );
}
void validateFirstName() {
  final value = firstNameController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      firstNameError = l10n.firstNameRequired;
    } else if (value.length < 3) {
      firstNameError = l10n.firstNameMin;
    } else if (value.length > 20) {
      firstNameError = l10n.firstNameMax;
    } else {
      firstNameError = null;
    }
  });
}

void validateLastName() {
  final value = lastNameController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      lastNameError = l10n.lastNameRequired;
    } else if (value.length < 3) {
      lastNameError = l10n.lastNameMin;
    } else if (value.length > 30) {
      lastNameError = l10n.lastNameMax;
    } else {
      lastNameError = null;
    }
  });
}

void validateEmail() {
  final value = emailController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  final emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  setState(() {
    if (value.isEmpty) {
      emailError = l10n.emailRequired;
    } else if (value.length < 10) {
      emailError = l10n.emailMin;
    } else if (value.length > 50) {
      emailError = l10n.emailMax;
    } else if (!emailRegex.hasMatch(value)) {
      emailError = l10n.emailInvalid;
    } else {
      emailError = null;
    }
  });
}
void validatePhone() {
  final value = phoneController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  final phoneRegex = RegExp(
    r'^\+?[0-9]{9,19}$',
  );

  setState(() {
    if (value.isEmpty) {
      phoneError = l10n.phoneRequired;
    } else if (value.length < 10) {
      phoneError = l10n.phoneMin;
    } else if (value.length > 20) {
      phoneError = l10n.phoneMax;
    } else if (!phoneRegex.hasMatch(value)) {
      phoneError = l10n.phoneInvalid;
    } else {
      phoneError = null;
    }
  });
}

void validatePassword() {
  final value = passwordController.text;
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      passwordError = l10n.passwordRequired;
    } else if (value.length < 6) {
      passwordError = l10n.passwordMin;
    } else if (value.length > 50) {
      passwordError = l10n.passwordMax;
    } else {
      passwordError = null;
    }
  });

  if (confirmPasswordController.text.isNotEmpty) {
    validateConfirmPassword();
  }
}

void validateConfirmPassword() {
  final value = confirmPasswordController.text;
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      confirmPasswordError = l10n.confirmPasswordRequired;
    } else if (value.length < 6) {
      confirmPasswordError = l10n.confirmPasswordMin;
    } else if (value.length > 50) {
      confirmPasswordError = l10n.confirmPasswordMax;
    } else if (value != passwordController.text) {
      confirmPasswordError = l10n.passwordsDoNotMatch;
    } else {
      confirmPasswordError = null;
    }
  });
}

void validateNeighborhood() {
  final value = neighborhoodController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      neighborhoodError = l10n.neighborhoodRequired;
    } else if (value.length < 5) {
      neighborhoodError = l10n.neighborhoodMin;
    } else if (value.length > 30) {
      neighborhoodError = l10n.neighborhoodMax;
    } else {
      neighborhoodError = null;
    }
  });
}

void validateAddress() {
  final value = addressController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      addressError = l10n.addressRequired;
    } else if (value.length < 10) {
      addressError = l10n.addressMin;
    } else if (value.length > 60) {
      addressError = l10n.addressMax;
    } else {
      addressError = null;
    }
  });
}

void validateExperience() {
  final value = experienceController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      experienceError = l10n.experienceRequired;
      return;
    }

    final number = int.tryParse(value);

    if (number == null) {
      experienceError = l10n.experienceDigits;
    } else if (number < 1 || number > 100) {
      experienceError = l10n.experienceRange;
    } else {
      experienceError = null;
    }
  });
}

void validateAbout() {
  final value = aboutController.text.trim();
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    if (value.isEmpty) {
      aboutError = l10n.aboutRequired;
    } else if (value.length < 10) {
      aboutError = l10n.aboutMin;
    } else if (value.length > 60) {
      aboutError = l10n.aboutMax;
    } else {
      aboutError = null;
    }
  });
}

Future<Map<String, bool>> checkRegistrationAvailability() async {
  try {
    final callable =
    FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('checkRegistrationAvailability');

    final result = await callable.call({
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    final data = Map<String, dynamic>.from(result.data);

    return {
      'emailExists': data['emailExists'] == true,
      'phoneExists': data['phoneExists'] == true,
    };
  } catch (e) {
    debugPrint("KAYIT KONTROL HATASI: $e");

    return {
      'emailExists': false,
      'phoneExists': false,
    };
  }
}
Future<bool> sendVerificationCode() async {
  try {
    final response = await http.post(
      Uri.parse(
        "https://europe-west1-usta-kapinda-e9ea7.cloudfunctions.net/sendVerificationCodeEmail",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": emailController.text.trim(),
      }),
    );

    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
Future<void> register() async {
  validateFirstName();
  validateLastName();
  validateEmail();
  validatePhone();
  validatePassword();
  validateConfirmPassword();
  validateNeighborhood();
  validateAddress();

  if (accountType == "craftsman") {
    validateExperience();
    validateAbout();
  }

  await Future.delayed(const Duration(milliseconds: 50));

  if (firstNameError != null ||
      lastNameError != null ||
      emailError != null ||
      phoneError != null ||
      passwordError != null ||
      confirmPasswordError != null ||
      neighborhoodError != null ||
      addressError != null ||
      (accountType == "craftsman" &&
          (experienceError != null || aboutError != null))) {
    return;
  }
if (firstNameController.text.trim().isEmpty ||
lastNameController.text.trim().isEmpty ||
emailController.text.trim().isEmpty ||
phoneController.text.trim().isEmpty ||
passwordController.text.isEmpty ||
confirmPasswordController.text.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
  content: Text(
    AppLocalizations.of(context)!.requiredFields,
  ),
),
);
return;
}

if (passwordController.text !=
confirmPasswordController.text) {
ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
  content: Text(
    AppLocalizations.of(context)!.passwordsDoNotMatch,
  ),
),
);
return;
}

if (!kvkk || !terms || !privacy) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          AppLocalizations.of(context)!.acceptLegalDocuments
      ),
    ),
  );
  return;
}

try {
  setState(() {
    isLoading = true;
  });

// E-POSTA VE TELEFONUN DAHA ÖNCE KULLANILIP
// KULLANILMADIĞINI KONTROL ET
  final availability = await checkRegistrationAvailability();

  if (!mounted) return;

  final emailExists = availability['emailExists'] ?? false;
  final phoneExists = availability['phoneExists'] ?? false;

  if (emailExists || phoneExists) {
    setState(() {
      if (emailExists) {
        emailError =
            AppLocalizations.of(context)!.emailAlreadyExists;
      }

      if (phoneExists) {
        phoneError =
            AppLocalizations.of(context)!.phoneAlreadyExists;
      }

      isLoading = false;
    });

    return;
  }

// MEVCUT E-POSTA DOĞRULAMA SİSTEMİ
  final success = await sendVerificationCode();
  if (!success) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.verificationCodeFailed,
        ),
      ),
    );

    return;
  }


  if (!mounted) return;

  final verified = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => VerificationCodePage(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,

        accountType: accountType,
        linkedUid: widget.linkedUid,

        city: cityController.text.trim(),
        district: districtController.text.trim(),
        neighborhood: neighborhoodController.text.trim(),
        address: addressController.text.trim(),

        professions: selectedProfessions,
        experience: int.tryParse(
          experienceController.text.trim(),
        ) ??
            0,
        about: aboutController.text.trim(),
      ),
    ),
  );

  if (verified != true) {
    return;
  }
  if (!mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    "/home",
        (route) => false,
  );

  return;
} on FirebaseAuthException catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
    e.message ??
        AppLocalizations.of(context)!.registrationFailed
),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
appBar: AppBar(
elevation: 0,
  backgroundColor: Colors.transparent,
  foregroundColor: Theme.of(context).colorScheme.onSurface,
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
children: [
Container(
width: 110,
height: 110,
decoration: BoxDecoration(
  color: Theme.of(context).colorScheme.primary,
borderRadius:
BorderRadius.circular(28),
boxShadow: [
BoxShadow(
  color: Theme.of(context)
      .colorScheme
      .primary
      .withOpacity(.35),
blurRadius: 25,
offset: const Offset(0, 10),
),
],
),
child: const Icon(
Icons.person_add_alt_1,
color: Colors.white,
size: 60,
),
),

const SizedBox(height: 20),

  Text(
    AppLocalizations.of(context)!.createNewAccount,
style: TextStyle(
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

  Text(
    accountType == "craftsman"
        ? AppLocalizations.of(context)!.createCraftsmanAccount
        : AppLocalizations.of(context)!.createCustomerAccount,
  style: TextStyle(
    color: Theme.of(context)
        .textTheme
        .bodyMedium
        ?.color
        ?.withOpacity(.7),
    fontSize: 16,
  ),
),

const SizedBox(height: 35),
  TextField(
    controller: firstNameController,
    maxLength: 20,
    onChanged: (_) => validateFirstName(),
    decoration: field(
      AppLocalizations.of(context)!.firstName,
      Icons.person_outline,
      errorText: firstNameError,
    ),
  ),

const SizedBox(height: 15),

  TextField(
    controller: lastNameController,
    maxLength: 30,
    onChanged: (_) => validateLastName(),
    decoration: field(
      AppLocalizations.of(context)!.lastName,
      Icons.badge_outlined,
      errorText: lastNameError,
    ),
  ),

const SizedBox(height: 15),

  TextField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    maxLength: 50,
    onChanged: (_) => validateEmail(),
    decoration: field(
      AppLocalizations.of(context)!.email,
      Icons.email_outlined,
      errorText: emailError,
    ),
  ),

const SizedBox(height: 15),

  TextField(
    controller: phoneController,
    keyboardType: TextInputType.phone,
    maxLength: 20,
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(r'[0-9+]'),
      ),
    ],
    onChanged: (_) => validatePhone(),
    decoration: field(
      AppLocalizations.of(context)!.phone,
      Icons.phone_outlined,
      errorText: phoneError,
    ),
  ),

const SizedBox(height: 15),

  TextField(
    controller: passwordController,
    obscureText: hidePassword,
    maxLength: 50,
    onChanged: (_) => validatePassword(),
    decoration: field(
      AppLocalizations.of(context)!.password,
      Icons.lock_outline,
      errorText: passwordError,
      suffix: IconButton(
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

const SizedBox(height: 15),

  TextField(
    controller: confirmPasswordController,
    obscureText: hideConfirm,
    maxLength: 50,
    onChanged: (_) => validateConfirmPassword(),
    decoration: field(
      AppLocalizations.of(context)!.confirmPassword,
      Icons.lock_reset,
      errorText: confirmPasswordError,
      suffix: IconButton(
        icon: Icon(
          hideConfirm
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            hideConfirm = !hideConfirm;
          });
        },
      ),
    ),
  ),

const SizedBox(height: 25),

    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        AppLocalizations.of(context)!.addressInformation,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

const SizedBox(height: 15),

  TextField(
    controller: cityController,
    readOnly: true,
    decoration: field(
      AppLocalizations.of(context)!.city,
      Icons.location_city,
      suffix: const Icon(Icons.arrow_drop_down),
    ),
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CitySearchDelegate(),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          cityController.text = result;
          districtController.clear();
        });
      }
    },
  ),

const SizedBox(height: 15),

  TextField(
    controller: districtController,
    readOnly: true,
    decoration: field(
      AppLocalizations.of(context)!.district,
      Icons.map_outlined,
      suffix: const Icon(Icons.arrow_drop_down),
    ),
    onTap: () async {
      if (cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.selectCityFirst,
            ),
          ),
        );
        return;
      }

      final result = await showSearch<String>(
        context: context,
        delegate: DistrictSearchDelegate(
          city: cityController.text,
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          districtController.text = result;
        });
      }
    },
  ),

const SizedBox(height: 15),

  TextField(
    controller: neighborhoodController,
    maxLength: 30,
    onChanged: (_) => validateNeighborhood(),
    decoration: field(
      AppLocalizations.of(context)!.neighborhood,
      Icons.home_work_outlined,
      errorText: neighborhoodError,
    ),
  ),

const SizedBox(height: 15),

  TextField(
    controller: addressController,
    maxLines: 3,
    maxLength: 60,
    onChanged: (_) => validateAddress(),
    decoration: field(
      AppLocalizations.of(context)!.address,
      Icons.home_outlined,
      errorText: addressError,
    ),
  ),

const SizedBox(height: 25),
  if (accountType == "craftsman") ...[
  Align(
  alignment: Alignment.centerLeft,
  child: Text(
    AppLocalizations.of(context)!.craftsmanInformation,
    style: const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
    ),
  ),
),

    const SizedBox(height: 15),

    TextField(
      controller: professionController,
      readOnly: true,
      decoration: field(
        AppLocalizations.of(context)!.professions,
        Icons.handyman_outlined,
        suffix: const Icon(Icons.arrow_drop_down),
      ),
      onTap: () async {
        final result = await showSearch<String>(
          context: context,
          delegate: CategorySearchDelegate(),
        );

        if (result != null &&
            result.isNotEmpty &&
            !selectedProfessions.contains(result)) {
          setState(() {
            selectedProfessions.add(result);
            professionController.text =
                selectedProfessions.join(", ");
          });
        }
      },
    ),
    const SizedBox(height: 10),

    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedProfessions.map((profession) {
        return Chip(
          label: Text(profession),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () {
            setState(() {
              selectedProfessions.remove(profession);
              professionController.text =
                  selectedProfessions.join(", ");
            });
          },
        );
      }).toList(),
    ),
    const SizedBox(height: 15),

    TextField(
      controller: experienceController,
      keyboardType: TextInputType.number,
      maxLength: 3,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (_) => validateExperience(),
      decoration: field(
        AppLocalizations.of(context)!.experienceYears,
        Icons.workspace_premium_outlined,
        errorText: experienceError,
      ),
    ),

    const SizedBox(height: 15),

    TextField(
      controller: aboutController,
      maxLines: 4,
      maxLength: 60,
      onChanged: (_) => validateAbout(),
      decoration: field(
        AppLocalizations.of(context)!.aboutYourself,
        Icons.description_outlined,
        errorText: aboutError,
      ),
    ),

    const SizedBox(height: 25),
  ],

  Column(
    children: [

      CheckboxListTile(
        value: kvkk,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) {
          setState(() {
            kvkk = v ?? false;
          });
        },
        title: Wrap(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/kvkk",
                );
              },
  child: Text(
  AppLocalizations.of(context)!.kvkk,
  style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

              Text(
              AppLocalizations.of(context)!.readAndAccept,
  ),
          ],
        ),
      ),
      CheckboxListTile(
        value: privacy,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) {
          setState(() {
            privacy = v ?? false;
          });
        },
        title: Wrap(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/privacy",
                );
              },
  child: Text(
  AppLocalizations.of(context)!.privacyPolicy,
  style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

              Text(
              AppLocalizations.of(context)!.readAndAccept,
              ),
          ],
        ),
      ),
      CheckboxListTile(
        value: terms,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) {
          setState(() {
            terms = v ?? false;
          });
        },
        title: Wrap(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/terms",
                );
              },
              child: Text(
                AppLocalizations.of(context)!.termsOfUse,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Text(
              AppLocalizations.of(context)!.readAndAccept,
            ),
          ],
        ),
      ),

    ],
  ),

  const SizedBox(height: 20),

  SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: isLoading ? null : register,
      style: ElevatedButton.styleFrom(
        backgroundColor:
        Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
        color: Colors.white,
      )
          : Text(
        AppLocalizations.of(context)!.createAccount,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(height: 20),

  TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Text(
      AppLocalizations.of(context)!.alreadyHaveAccount,
      style: const TextStyle(
        fontSize: 16,
      ),
    ),
  ),
  const SizedBox(height: 25),
],
),
),
),
);
}
}