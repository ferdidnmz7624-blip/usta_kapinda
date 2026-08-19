import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'add_job_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../services/user_service.dart';
import '../screens/customer_home_page.dart';
import '../screens/craftsman_home_page.dart';
import '../generated/app_localizations.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentIndex = 0;

  final List<Widget> pages =  [
    HomePage(),
    SearchPage(),
    AddJobPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print("NavigationPage çalıştı");

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          print("Tıklanan index: $index");

          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: l10n.search,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: l10n.postListing,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: l10n.favorites,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}