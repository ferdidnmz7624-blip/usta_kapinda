import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final UserService _userService = UserService();

  UserModel? user;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final data = await _userService.getUser(currentUser.uid);

    if (!mounted) return;

    setState(() {
      user = data;
      loading = false;
    });
  }

  Widget infoTile(
      IconData icon,
      Color color,
      String title,
      String value,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.accountInformation,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          infoTile(
            Icons.person,
            Colors.blue,
            AppLocalizations.of(context)!.firstName,
            user?.firstName ?? "",
          ),

          infoTile(
            Icons.person_outline,
            Colors.indigo,
            AppLocalizations.of(context)!.lastName,
            user?.lastName ?? "",
          ),

          infoTile(
            Icons.email,
            Colors.orange,
            AppLocalizations.of(context)!.email,
            user?.email ?? "",
          ),

          infoTile(
            Icons.phone,
            Colors.green,
            AppLocalizations.of(context)!.phone,
            user?.phone ?? "",
          ),

          infoTile(
            Icons.location_city,
            Colors.teal,
            AppLocalizations.of(context)!.city,
            user?.city ?? "",
          ),

          infoTile(
            Icons.badge,
            Colors.deepPurple,
            AppLocalizations.of(context)!.accountType,
            user?.activeMode == "craftsman"
                ? AppLocalizations.of(context)!.craftsman
                : AppLocalizations.of(context)!.customer,
          ),
        ],
      ),
    );
  }
}