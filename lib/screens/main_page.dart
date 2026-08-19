import 'package:flutter/material.dart';

import 'favorites_page.dart';
import 'home_page.dart';
import 'jobs_page.dart';
import 'profile_page.dart';
import '../generated/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    JobsPage(),
    Scaffold(
      body: Center(
        child: Text(
          "Mesajlar",
          style: const TextStyle(fontSize: 28),
        ),
      ),
    ),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: l10n.latestListings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: l10n.messages,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: l10n.favorites,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}