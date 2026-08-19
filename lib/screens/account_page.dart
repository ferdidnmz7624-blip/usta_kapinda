import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart';
import '../generated/app_localizations.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final UserService _userService = UserService();

  UserModel? userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final data = await _userService.getUser(currentUser.uid);

    if (!mounted) return;

    setState(() {
      userModel = data;
      isLoading = false;
    });
  }

  Widget infoTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? "-" : value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.myAccount,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            CircleAvatar(
              radius: 55,
              child: Text(
                "${userModel?.firstName.substring(0,1) ?? ""}${userModel?.lastName.substring(0,1) ?? ""}",
                style: const TextStyle(fontSize: 28),
              ),
            ),

            const SizedBox(height: 20),

            infoTile(
              Icons.person,
              AppLocalizations.of(context)!.fullName,
              "${userModel?.firstName ?? ""} ${userModel?.lastName ?? ""}",
            ),

            infoTile(
              Icons.phone,
              AppLocalizations.of(context)!.phone,
              userModel?.phone ?? "",
            ),

            infoTile(
              Icons.email,
              AppLocalizations.of(context)!.email,
              userModel?.email ?? "",
            ),

            infoTile(
              Icons.location_city,
              AppLocalizations.of(context)!.city,
              userModel?.city ?? "",
            ),

            infoTile(
              Icons.map,
              AppLocalizations.of(context)!.district,
              userModel?.district ?? "",
            ),

            infoTile(
              Icons.home,
              AppLocalizations.of(context)!.neighborhood,
              userModel?.neighborhood ?? "",
            ),

            infoTile(
              Icons.location_on,
              AppLocalizations.of(context)!.address,
              userModel?.address ?? "",
            ),

            if (userModel?.accountType == "craftsman") ...[

              infoTile(
                Icons.work,
                AppLocalizations.of(context)!.professions,
                userModel?.professions.join(", ") ?? "",
              ),

              infoTile(
                Icons.star,
                AppLocalizations.of(context)!.experienceYears,
                "${userModel?.experience ?? 0} ${AppLocalizations.of(context)!.years}",
              ),

              infoTile(
                Icons.handyman,
                AppLocalizations.of(context)!.completedJobs,
                "${userModel?.completedJobs ?? 0}",
              ),

              infoTile(
                Icons.info,
                AppLocalizations.of(context)!.aboutMe,
                userModel?.about ?? "",
              ),
            ],

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: Text(
                  AppLocalizations.of(context)!.editInformation,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );

                  loadUser();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}