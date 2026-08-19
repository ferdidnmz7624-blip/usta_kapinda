import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'mode_router_page.dart';
import 'complete_second_profile_page.dart';
import 'login_page.dart';
import '../generated/app_localizations.dart';

class SwitchAccountPage extends StatefulWidget {
  const SwitchAccountPage({super.key});

  @override
  State<SwitchAccountPage> createState() => _SwitchAccountPageState();
}

class _SwitchAccountPageState extends State<SwitchAccountPage> {
  final UserService _userService = UserService();

  bool isLoading = true;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final data = await _userService.getUser(firebaseUser.uid);

    if (!mounted) return;

    setState(() {
      user = data;
      isLoading = false;
    });
  }
  Future<void> switchToCustomer() async {
    if (user == null) return;

    // Bağlı müşteri hesabı yoksa oluştur
    if (user!.linkedCustomerUid.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CompleteSecondProfilePage(
            accountType: "customer",
          ),
        ),
      );
      return;
    }

    final linkedUser =
    await _userService.getUser(user!.linkedCustomerUid);

    if (linkedUser == null) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          initialEmail: linkedUser.email,
          isSwitchAccount: true,
        ),
      ),
          (route) => false,
    );
  }

  Future<void> switchToCraftsman() async {
    if (user == null) return;

    // Bağlı usta hesabı yoksa oluştur
    if (user!.linkedCraftsmanUid.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CompleteSecondProfilePage(
            accountType: "craftsman",
          ),
        ),
      );
      return;
    }

    final linkedUser =
    await _userService.getUser(user!.linkedCraftsmanUid);

    if (linkedUser == null) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          initialEmail: linkedUser.email,
          isSwitchAccount: true,
        ),
      ),
          (route) => false,
    );
  }
  Widget accountCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback? onTap,
  }) {
    return Stack(
      children: [
      Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: onTap == null ? Colors.green : color.withOpacity(0.4),
          width: onTap == null ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withOpacity(.15),
              child: Icon(
                icon,
                color: color,
                size: 35,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onTap == null
                      ? Colors.green
                      : color,
                  foregroundColor: Colors.white,
                  elevation: onTap == null ? 0 : 3,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onTap == null) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),

        if (onTap == null)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppLocalizations.of(context)!.active,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(l10n.userNotFound),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changeAccountType),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            accountCard(
              icon: Icons.person,
              color: Colors.blue,
              title: l10n.customer,
              description: l10n.customerAccountDescription,
              buttonText: user!.accountType == "customer"
                  ? l10n.loggedInWithThisAccount
                  : user!.linkedCustomerUid.isEmpty
                  ? l10n.createCustomerAccount
                  : l10n.switchToCustomerAccount,

              onTap: user!.accountType == "customer"
                  ? null
                  : switchToCustomer,
            ),
            const SizedBox(height: 20),
            accountCard(
              icon: Icons.handyman,
              color: Colors.orange,
              title: l10n.craftsman,
              description: l10n.craftsmanAccountDescription,
              buttonText: user!.accountType == "craftsman"
                  ? l10n.loggedInWithThisAccount
                  : user!.linkedCraftsmanUid.isEmpty
                  ? l10n.createCraftsmanAccount
                  : l10n.switchToCraftsmanAccount,

              onTap: user!.accountType == "craftsman"
                  ? null
                  : switchToCraftsman,
            ),
          ],
        ),
      ),
    );
  }
}