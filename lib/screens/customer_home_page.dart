import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'job_post_page.dart';
import 'jobs_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import '../pages/notifications_page.dart';
import '../widgets/notification_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_page.dart';
import '../generated/app_localizations.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final AuthService _authService = AuthService();
  String firstName = "";
  String city = "";
  double rating = 0;
  bool isLoading = true;
  String? accountType;

  int selectedIndex = 0;

  List<Map<String, dynamic>> categories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      {
        "title": l10n.plumbing,
        "icon": Icons.plumbing,
      },
      {
        "title": l10n.electricity,
        "icon": Icons.electrical_services,
      },
      {
        "title": l10n.airConditioning,
        "icon": Icons.ac_unit,
      },
      {
        "title": l10n.painting,
        "icon": Icons.format_paint,
      },
      {
        "title": l10n.furniture,
        "icon": Icons.carpenter,
      },
      {
        "title": l10n.cleaning,
        "icon": Icons.cleaning_services,
      },
      {
        "title": l10n.construction,
        "icon": Icons.construction,
      },
      {
        "title": l10n.roofing,
        "icon": Icons.roofing,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    accountType = await _authService.getAccountType();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = doc.data();

    firstName = data?["firstName"] ?? "";

    city = data?["city"] ?? "";

    rating = (data?["rating"] ?? 0).toDouble();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,

        title: const Text(
          "Usta Kapında",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        actions: [
          NotificationBadge(),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

// ÜST MAVİ PANEL

            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                        Text(
                        "${l10n.hello} $firstName 👋",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              l10n.whatServiceDoYouNeed,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                          BorderRadius.circular(15),
                        ),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationsPage(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    height: 58,

                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.craftsmanAtYourDoor,
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),

                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(.6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius:
                            BorderRadius.circular(18),
                          ),

                          child: Column(
                            children: [

                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),

                              SizedBox(height: 8),

                              Text(
                                city,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius:
                            BorderRadius.circular(18),
                          ),

                          child: Column(
                            children: [

                              Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),

                              SizedBox(height: 8),

                              Text(
                                "${rating.toStringAsFixed(1)} ${l10n.points}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        if (accountType == "Hizmet Veren") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobsPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const JobPostPage(),
                            ),
                          );
                        }
                      },

                      icon: Icon(
                        accountType == "Hizmet Veren"
                            ? Icons.work
                            : Icons.add_box,
                      ),

    label: Text(
    accountType == "Hizmet Veren"
    ? l10n.viewListings
        : l10n.postListing,
    ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Row(
              children: [
                Expanded(
                  child: Text(
    l10n.serviceCategories,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JobPostPage(),
                      ),
                    );
                  },
    child: Text(l10n.seeAll),
                ),
              ],
            ),

            const SizedBox(height: 20),

            GridView.builder(
    itemCount: categories(context).length,

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),

              itemBuilder: (context, index) {
    final item = categories(context)[index];

                return InkWell(
                  borderRadius:
                  BorderRadius.circular(20),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JobPostPage(),
                      ),
                    );
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,

                      borderRadius:
                      BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        Container(
                          padding:
                          const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(.12),
                          ),

                          child: Icon(
                            item["icon"],
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: Text(
                              item["title"],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                height: 1.15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff0D47A1),
                    Color(0xff42A5F5),
                  ],
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [

    Text(
    l10n.bestCraftsmen,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

    Text(
    l10n.discoverTopRatedCraftsmen,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).cardColor,
                              foregroundColor:
                              Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                l10n.discoverCraftsmen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _jobCard({
    required IconData icon,
    required String title,
    required String location,
    required String price,
    required Color color,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),

        ],
      ),

      child: Row(

        children: [

          Container(

            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),

          ),

          const SizedBox(width: 18),

          Flexible(
            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Row(

                  children: [

                    const Icon(
                      Icons.location_on,
                      size: 17,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  ],

                ),

              ],

            ),

          ),

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.end,

            children: [

              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        price,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: 100,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        child: FittedBox(
                          child: Text(l10n.makeOffer),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            ],

          ),

        ],

      ),

    );

  }

}