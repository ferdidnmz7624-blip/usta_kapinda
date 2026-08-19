import 'package:flutter/material.dart';

import 'craftsman_home_page.dart';
import 'profile_page.dart';
import 'jobs_page.dart';
import 'craftsman_offers_page.dart';
import '../pages/chat_list_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../generated/app_localizations.dart';

class CraftsmanNavigationPage extends StatefulWidget {
  const CraftsmanNavigationPage({super.key});

  @override
  State<CraftsmanNavigationPage> createState() =>
      _CraftsmanNavigationPageState();
}

class _CraftsmanNavigationPageState
    extends State<CraftsmanNavigationPage> {
  int currentIndex = 0;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final List<Widget> pages = [
    const CraftsmanHomePage(),
    const JobsPage(),
    const CraftsmanOffersPage(),
    ChatListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: AppLocalizations.of(context)!.jobs,
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake),
            label: AppLocalizations.of(context)!.offers,
          ),
          NavigationDestination(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where("users", arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int unread = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    if (data["unreadCount"] != null) {
                      unread +=
                      (data["unreadCount"][currentUser.uid] ?? 0)
                      as int;
                    }
                  }
                }

                return badges.Badge(
                  showBadge: unread > 0,
                  badgeContent: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  child: const Icon(Icons.chat),
                );
              },
            ),
            label: AppLocalizations.of(context)!.messages,
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}