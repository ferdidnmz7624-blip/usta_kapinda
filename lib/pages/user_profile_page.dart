
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../generated/app_localizations.dart';

class UserProfilePage extends StatelessWidget {
final String userId;

const UserProfilePage({
super.key,
required this.userId,
});

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;

return Scaffold(
appBar: AppBar(
title: Text(l10n.profile),
),
body: StreamBuilder(
stream: FirebaseFirestore.instance
    .collection('public_profiles')
    .doc(userId)
    .snapshots(),
builder: (context, snapshot) {
if (!snapshot.hasData ||
snapshot.data?.data() == null) {
return const Center(
child: CircularProgressIndicator(),
);
}

final user = UserModel.fromMap(
snapshot.data!.data() as Map<String, dynamic>,
);

return SingleChildScrollView(
child: Column(
children: [
const SizedBox(height: 25),

CircleAvatar(
radius: 55,
backgroundImage: user.profilePhoto.isNotEmpty
? NetworkImage(user.profilePhoto)
    : null,
child: user.profilePhoto.isEmpty
? const Icon(
Icons.person,
size: 60,
)
    : null,
),

const SizedBox(height: 15),

Text(
"${user.firstName} ${user.lastName}",
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
user.isOnline
? "🟢 ${l10n.activeNow}"
    : "⚪ ${l10n.offline}",
style: TextStyle(
color: user.isOnline
? Colors.green
    : Colors.grey,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 25),

const SizedBox(height: 20),

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 16,
),
child: Row(
children: [
Expanded(
child: _ProfileStat(
icon: Icons.star,
color: Colors.amber,
title: l10n.rating,
value: user.rating
    .toStringAsFixed(1),
),
),

const SizedBox(width: 12),

Expanded(
child: _ProfileStat(
icon: Icons.work_history,
color: Colors.green,
title: user.craftsmanProfile
? l10n.job
    : l10n.listing,
value: user.completedJobs
    .toString(),
),
),

const SizedBox(width: 12),

Expanded(
child: _ProfileStat(
icon: Icons.favorite,
color: Colors.red,
title: l10n.favorite,
value: "0",
),
),
],
),
),

const SizedBox(height: 30),

Card(
margin: const EdgeInsets.symmetric(
horizontal: 16,
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
if (user.craftsmanProfile) ...[
Text(
l10n.profession,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
user.professions.join(", "),
),

const SizedBox(height: 16),

Text(
l10n.experience,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
"${user.experience} ${l10n.year}",
),

const SizedBox(height: 16),
],

Text(
l10n.city,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(user.city),

const SizedBox(height: 16),

Text(
l10n.about,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
user.about.isEmpty
? l10n.noAboutInfo
    : user.about,
),
],
),
),
),

const SizedBox(height: 20),
],
),
);
},
),
);
}
}

class _ProfileStat extends StatelessWidget {
final IconData icon;
final Color color;
final String title;
final String value;

const _ProfileStat({
required this.icon,
required this.color,
required this.title,
required this.value,
});

@override
Widget build(BuildContext context) {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 18,
horizontal: 12,
),
child: Column(
children: [
Icon(
icon,
color: color,
size: 30,
),

const SizedBox(height: 6),

Text(
value,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

Text(title),
],
),
),
);
}
}
