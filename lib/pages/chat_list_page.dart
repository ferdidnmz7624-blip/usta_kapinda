import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(l10n.sessionNotFound),
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: _userService.getUser(currentUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data!;
        final isCustomer = user.activeMode == "customer";

        return Scaffold(
          backgroundColor: const Color(0xffF5F7FB),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
            title: Text(
              l10n.messages,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("users", arrayContains: currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(l10n.errorOccurred),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final chats = snapshot.data!.docs.toList();

              chats.removeWhere((doc) {
                final data = doc.data() as Map<String, dynamic>;

                if (data["deletedBy"] == null) return false;

                final deletedBy =
                Map<String, dynamic>.from(data["deletedBy"]);

                return deletedBy[currentUser.uid] == true;
              });

              chats.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final ta =
                aData["lastMessageTime"] as Timestamp?;
                final tb =
                bData["lastMessageTime"] as Timestamp?;

                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;

                return tb.compareTo(ta);
              });

              if (chats.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noChats,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chatDoc = chats[index];
                  final chat =
                  chatDoc.data() as Map<String, dynamic>;

                  final users =
                  List<String>.from(chat["users"] ?? []);

                  final otherUser = users.firstWhere(
                        (id) => id != currentUser.uid,
                    orElse: () => "",
                  );

                  return FutureBuilder<UserModel?>(
                    future: _userService.getUser(otherUser),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(l10n.loading),
                            ),
                          ),
                        );
                      }

                      final other = userSnapshot.data!;

                      final profilePhoto =
                          other.profilePhoto ?? "";

                      final isOnline =
                          other.isOnline ?? false;

                      final profession =
                      other.professions.join(" • ");

                      final lastMessage =
                          chat["lastMessage"] ?? "";

                      final Timestamp? time =
                      chat["lastMessageTime"] as Timestamp?;

                      String hour = "";

                      if (time != null) {
                        final dt = time.toDate();

                        hour =
                        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                      }

                      final unreadMap =
                      Map<String, dynamic>.from(
                        chat["unreadCount"] ?? {},
                      );

                      final unread =
                          unreadMap[currentUser.uid] ?? 0;

                      return Padding(
                        padding:
                        const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(18),
                          elevation: 3,
                          child: InkWell(
                            borderRadius:
                            BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    chatId: chatDoc.id,
                                    receiverId: otherUser,
                                    receiverName:
                                    "${other.firstName} ${other.lastName}",
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundImage:
                                        profilePhoto.isNotEmpty
                                            ? NetworkImage(
                                          profilePhoto,
                                        )
                                            : null,
                                        child:
                                        profilePhoto.isEmpty
                                            ? const Icon(
                                          Icons.person,
                                          size: 34,
                                        )
                                            : null,
                                      ),
                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration:
                                          BoxDecoration(
                                            color: isOnline
                                                ? Colors.green
                                                : Colors.grey,
                                            border:
                                            Border.all(
                                              color:
                                              Colors.white,
                                              width: 2,
                                            ),
                                            shape:
                                            BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${other.firstName} ${other.lastName}",
                                                style:
                                                const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .end,
                                              children: [
                                                Text(
                                                  hour,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .grey
                                                        .shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (unread > 0)
                                                  Container(
                                                    margin:
                                                    const EdgeInsets
                                                        .only(
                                                      top: 5,
                                                    ),
                                                    padding:
                                                    const EdgeInsets
                                                        .all(6),
                                                    decoration:
                                                    const BoxDecoration(
                                                      color:
                                                      Colors.red,
                                                      shape:
                                                      BoxShape
                                                          .circle,
                                                    ),
                                                    child: Text(
                                                      unread > 99
                                                          ? "99+"
                                                          : unread
                                                          .toString(),
                                                      style:
                                                      const TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration:
                                              BoxDecoration(
                                                color: Colors
                                                    .deepPurple,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                  30,
                                                ),
                                              ),
                                              child: Text(
                                                isCustomer
                                                    ? l10n.craftsman
                                                    : l10n.customer,
                                                style:
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                profession,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                                style: TextStyle(
                                                  color: Colors
                                                      .grey
                                                      .shade700,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          lastMessage,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors
                                                .grey
                                                .shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }
}