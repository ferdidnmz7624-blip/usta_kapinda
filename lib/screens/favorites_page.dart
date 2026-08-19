import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/favorite_service.dart';
import '../services/user_service.dart';
import '../pages/user_profile_page.dart';
import '../generated/app_localizations.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoriteService _favoriteService = FavoriteService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print("FavoritesPage açıldı");
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
        centerTitle: true,
      ),
      body: StreamBuilder<List<String>>(
        stream: _favoriteService.getFavoriteIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final ids = snapshot.data!;

          if (ids.isEmpty) {
            return Center(
              child: Text(l10n.noFavoritesYet),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<UserModel?>(
                future: _userService.getUser(ids[index]),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final user = userSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(
                              userId: user.uid,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: user.profilePhoto.isNotEmpty
                            ? NetworkImage(user.profilePhoto)
                            : null,
                        child: user.profilePhoto.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text("${user.firstName} ${user.lastName}"),
                      subtitle: Text(
                        user.activeMode == "craftsman"
                            ? user.professions.join(", ")
                            : l10n.customer,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _favoriteService.removeFavorite(user.uid);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}