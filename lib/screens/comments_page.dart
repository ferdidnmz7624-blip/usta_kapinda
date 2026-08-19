import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../generated/app_localizations.dart';

class CommentsPage extends StatelessWidget {
  final String userId;
  final String userName;

  const CommentsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$userName ${AppLocalizations.of(context)!.reviews}",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("reviews")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reviews = snapshot.data!.docs;

          if (reviews.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noCommentsYet,
              ),
            );
          }

          double total = 0;

          for (final review in reviews) {
            total +=
                (review["rating"] as num).toDouble();
          }

          final average =
              total / reviews.length;

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 45,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        average.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${reviews.length} ${AppLocalizations.of(context)!.reviews}",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ...reviews.map((doc) {
                final data =
                doc.data() as Map<String, dynamic>;

                final fullName =
                (data["userName"] ?? "Kullanıcı").toString();

                final names = fullName.split(" ");

                String hiddenName = fullName;

                if (names.length >= 2) {
                  hiddenName =
                  "${names[0][0]}..... ${names[1][0]}.....";
                }

                return Card(
                  color: Colors.amber.shade100,
                  elevation: 3,
                  margin:
                  const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor:
                              Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Colors.orange,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                hiddenName,
                                style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: List.generate(
                            5,
                                (index) {
                              return Icon(
                                Icons.star,
                                color:
                                index < data["rating"]
                                    ? Colors.amber
                                    : Colors.grey,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          data["comment"] ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}