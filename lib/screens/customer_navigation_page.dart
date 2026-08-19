import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'customer_home_page.dart';
import 'search_page.dart';
import 'my_jobs_page.dart';
import 'profile_page.dart';
import '../pages/chat_list_page.dart';
import '../generated/app_localizations.dart';

class CustomerNavigationPage extends StatefulWidget {
  const CustomerNavigationPage({super.key});

  @override
  State<CustomerNavigationPage> createState() =>
      _CustomerNavigationPageState();
}

class _CustomerNavigationPageState
    extends State<CustomerNavigationPage> {
  int currentIndex = 0;

  final currentUser = FirebaseAuth.instance.currentUser!;

  final List<Widget> pages = [
    const CustomerHomePage(),
    const SearchPage(),
    MyJobsPage(),
    ChatListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildItem(
                index: 0,
                icon: Icons.home,
                label: l10n.home,
              ),

              _buildItem(
                index: 1,
                icon: Icons.search,
                label: l10n.discoverCraftsmen,
              ),

              _buildOffersItem(
                index: 2,
                label: l10n.myListings,
              ),

              _buildMessagesItem(
                index: 3,
                label: l10n.messages,
              ),

              _buildItem(
                index: 4,
                icon: Icons.person,
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.orange : Colors.grey,
              size: 25,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersItem({
    required int index,
    required String label,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("offers")
              .where(
            "customerId",
            isEqualTo: currentUser.uid,
          )
              .where(
            "isSeenByCustomer",
            isEqualTo: false,
          )
              .snapshots(),
          builder: (context, snapshot) {
            final count =
                snapshot.data?.docs.length ?? 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                badges.Badge(
                  showBadge: count > 0,
                  badgeContent: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color:
                    selected ? Colors.orange : Colors.grey,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color:
                    selected ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessagesItem({
    required int index,
    required String label,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where(
            "users",
            arrayContains: currentUser.uid,
          )
              .snapshots(),
          builder: (context, snapshot) {
            int unread = 0;

            if (snapshot.hasData) {
              for (final doc in snapshot.data!.docs) {
                final data =
                doc.data() as Map<String, dynamic>;

                if (data["unreadCount"] != null) {
                  unread +=
                  (data["unreadCount"]
                  [currentUser.uid] ??
                      0) as int;
                }
              }
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                badges.Badge(
                  showBadge: unread > 0,
                  badgeContent: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  child: Icon(
                    Icons.chat,
                    color:
                    selected ? Colors.orange : Colors.grey,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color:
                    selected ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}