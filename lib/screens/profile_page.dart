import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/google_auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'account_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'switch_account_page.dart';
import 'wallet_page.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import 'wallet_deposit_page.dart';
import '../generated/app_localizations.dart';
import 'comments_page.dart';
import 'favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
final UserService _userService = UserService();
final ReviewService _reviewService = ReviewService();
final ImagePicker _picker = ImagePicker();

UserModel? userModel;
File? profileImage;

bool isLoading = true;

@override
void initState() {
super.initState();
loadUser();
}
String get successRate {
  if (userModel == null) return "0";
  if (userModel!.completedJobs == 0) {
    return "0";
  }

  final success =
  ((userModel!.rating / 5) * 100).round();

  return success.toString();
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
double get averageRating {
  return userModel?.rating ?? 0;
}
Future<void> pickImage() async {
  final image = await _picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image == null) return;

  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) return;

  final file = File(image.path);

  setState(() {
    profileImage = file;
  });

  final storageRef = FirebaseStorage.instance
      .ref()
      .child("profile_photos")
      .child("${currentUser.uid}.jpg");

  print("UID: ${currentUser.uid}");
  print("Yüklenecek yol: ${storageRef.fullPath}");

  try {
    await storageRef.putFile(file);

    final photoUrl = await storageRef.getDownloadURL();

    print("Download URL: $photoUrl");

    await _userService.updateProfilePhoto(
      currentUser.uid,
      photoUrl,
    );

    print("Firestore güncellendi.");

    await loadUser();
  } catch (e) {
    print("PROFIL FOTO HATASI: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Hata: $e"),
      ),
    );
  }
}
Stream<int> get reviewCount {
  return _reviewService
      .getCraftsmanReviews(
    FirebaseAuth.instance.currentUser!.uid,
  )
      .map((event) => event.length);
}
Widget statCard(
String title,
String value,
IconData icon,
Color color,
) {
return Expanded(
child: Container(
padding: const EdgeInsets.symmetric(
vertical: 18,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.05),
blurRadius: 15,
),
],
),
child: Column(
children: [
Icon(icon, color: color),
const SizedBox(height: 10),
Text(
value,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
title,
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
);
}

Widget menuTile({
required IconData icon,
required String title,
required VoidCallback onTap,
Color color = Colors.blue,
}) {
return Card(
margin: const EdgeInsets.only(bottom: 12),
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
child: ListTile(
leading: CircleAvatar(
backgroundColor: color.withOpacity(.12),
child: Icon(icon, color: color),
),
title: Text(
title,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
trailing: const Icon(Icons.arrow_forward_ios, size: 18),
onTap: onTap,
),
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
backgroundColor: const Color(0xffF5F7FA),
body: SingleChildScrollView(
child: Column(
children: [

Container(
width: double.infinity,
padding: const EdgeInsets.only(
top: 60,
left: 20,
right: 20,
bottom: 30,
),
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [
Color(0xff1565C0),
Color(0xff42A5F5),
],
),
borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(35),
bottomRight: Radius.circular(35),
),
),
child: Column(
children: [

Stack(
children: [

GestureDetector(
onTap: pickImage,
child: CircleAvatar(
radius: 55,
backgroundColor: Colors.white,
  backgroundImage: profileImage != null
      ? FileImage(profileImage!)
      : (userModel?.profilePhoto.isNotEmpty == true
      ? NetworkImage(userModel!.profilePhoto)
      : null) as ImageProvider?,
  child: (profileImage == null &&
      (userModel?.profilePhoto.isEmpty ?? true))
      ? const Icon(
    Icons.person,
    size: 60,
    color: Colors.blue,
  )
      : null,
),
),

Positioned(
right: 0,
bottom: 0,
child: CircleAvatar(
backgroundColor: Colors.orange,
radius: 18,
child: const Icon(
Icons.camera_alt,
color: Colors.white,
size: 18,
),
),
),
],
),

const SizedBox(height: 18),

Text(
"${userModel?.firstName ?? ""} ${userModel?.lastName ?? ""}",
style: const TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
userModel?.email ?? "",
style: const TextStyle(
color: Colors.white70,
),
),

const SizedBox(height: 18),



SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: Colors.blue,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const EditProfilePage(),
),
).then((_) => loadUser());
},
  icon: const Icon(Icons.edit),
  label: Text(l10n.profileEditing),
),
),
],
),
),

Padding(
padding: const EdgeInsets.all(18),
child: Column(
children: [

  Row(
    children: [

statCard(
l10n.jobs,
  "${userModel?.completedJobs ?? 0}",
        Icons.work,
        Colors.blue,
      ),

      const SizedBox(width: 10),

  statCard(
    l10n.rating,
    averageRating.toStringAsFixed(1),
        Icons.star,
        Colors.amber,
      ),

    ],
  ),

  const SizedBox(height: 10),

  Row(
    children: [

      StreamBuilder<int>(
        stream: reviewCount,
        builder: (context, snapshot) {
          return statCard(
            l10n.reviews,
            "${snapshot.data ?? 0}",
            Icons.chat,
            Colors.green,
          );
        },
      ),

      const SizedBox(width: 10),

      statCard(
        l10n.success,
        "%$successRate",
        Icons.verified,
        Colors.deepPurple,
      ),

    ],
  ),
    const SizedBox(height: 20),

    if (userModel?.activeMode == "craftsman") ...[
  Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.18),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
        ],
      ),
    ),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

  Text(
    l10n.tokenBalance,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),
  const Align(
    alignment: Alignment.topRight,
    child: Icon(
      Icons.account_balance_wallet_rounded,
      color: Colors.white24,
      size: 40,
    ),
  ),
const SizedBox(height: 10),

Text(
  "${userModel?.tokens ?? 0} 🪙",
  style: const TextStyle(
  fontSize: 38,
  fontWeight: FontWeight.bold,
  color: Color(0xFFFFD54F),
  ),
),

const SizedBox(height: 18),

Row(
children: [

  Expanded(
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WalletDepositPage(),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: Text(l10n.buyTokens),
    ),
  ),
],
),
],
),
),
    ],
const SizedBox(height: 25),
  const SizedBox(height: 25),

  menuTile(
    icon: Icons.chat,
    color: Colors.green,
  title: l10n.reviews,
  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommentsPage(
            userId: FirebaseAuth.instance.currentUser!.uid,
            userName:
            "${userModel?.firstName ?? ""} ${userModel?.lastName ?? ""}",
          ),
        ),
      );
    },
  ),
  menuTile(
    icon: Icons.person,
    title: l10n.myAccount,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AccountPage(),
        ),
      );
    },
  ),

  menuTile(
    icon: Icons.favorite,
    color: Colors.red,
    title: l10n.favorites,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesPage(),
        ),
      );
    },
  ),

  menuTile(
    icon: Icons.star_rate_rounded,
    color: Colors.amber,
    title: l10n.rateUs,
    onTap: () {
      // Daha sonra Play Store / App Store yönlendirmesi eklenecek.
    },
  ),
  menuTile(
    icon: Icons.settings,
    title: l10n.settings,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        ),
      );
    },
  ),

  menuTile(
    icon: Icons.support_agent,
    color: Colors.green,
    title: l10n.supportCenter,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SupportPage(),
        ),
      );
    },
  ),

  menuTile(
    icon: Icons.swap_horiz,
    color: Colors.deepPurple,
    title: l10n.changeAccountType,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SwitchAccountPage(),
        ),
      );
    },
  ),

  if (userModel?.activeMode == "craftsman") ...[
    menuTile(
      icon: Icons.account_balance_wallet,
      color: Colors.teal,
      title: l10n.accountActivity,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WalletPage(),
          ),
        );
      },
    ),
  ],

  menuTile(
    icon: Icons.logout,
    color: Colors.red,
    title: l10n.logout,
    onTap: () async {
      await GoogleAuthService().signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        "/login",
            (route) => false,
      );
    },
  ),
],
),
),
],
),
),
);
}
}
