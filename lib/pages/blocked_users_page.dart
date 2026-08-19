import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blockedUsers),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getBlockedUsers(currentUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
            return Center(
              child: Text(l10n.noBlockedUsers),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: user.profilePhoto.isNotEmpty
                            ? NetworkImage(user.profilePhoto)
                            : null,
                        child: user.profilePhoto.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 35,
                        )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (user.professions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            user.professions.join(", "),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(height: 6),

                      Text(
                        "⭐ ${user.rating.toStringAsFixed(1)}",
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await _userService.unblockUser(
                              currentUserId: currentUser.uid,
                              blockedUserId: user.uid,
                            );
                          },
                          child: Text(l10n.unblock),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}