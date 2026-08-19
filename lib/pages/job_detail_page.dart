import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/job_model.dart';
import '../screens/offer_page.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';

class JobDetailPage extends StatefulWidget {
final JobModel job;

const JobDetailPage({
super.key,
required this.job,
});

@override
State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
final UserService _userService = UserService();

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;

return Scaffold(
appBar: AppBar(
title: Text(l10n.listingDetail),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(16),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

Text(
widget.job.title,
style: const TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

Card(
child: ListTile(
leading: const Icon(Icons.category),
title: Text(l10n.category),
subtitle: Text(widget.job.category),
),
),

const SizedBox(height: 12),

Card(
child: ListTile(
leading: const Icon(Icons.location_on),
title: Text(l10n.location),
subtitle: Text(
"${widget.job.city} / ${widget.job.district}",
),
),
),

const SizedBox(height: 12),

Card(
child: ListTile(
leading: const Icon(Icons.attach_money),
title: Text(l10n.budget),
subtitle: Text(
"${widget.job.budget.toStringAsFixed(0)} ₺",
),
),
),

const SizedBox(height: 12),

Card(
child: ListTile(
leading: const Icon(Icons.info_outline),
title: Text(l10n.status),
subtitle: Row(
children: [

Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),

decoration: BoxDecoration(
color: widget.job.status == "active"
? Colors.green.shade100
    : Colors.red.shade100,
borderRadius: BorderRadius.circular(20),
),

child: Text(
widget.job.status == "active"
? l10n.active
    : l10n.closedStatus,

style: TextStyle(
color: widget.job.status == "active"
? Colors.green
    : Colors.red,

fontWeight: FontWeight.bold,
),
),
),
],
),
),
),

const SizedBox(height: 20),

Text(
l10n.description,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Card(
child: Padding(
padding: const EdgeInsets.all(16),

child: Text(
widget.job.description,
style: const TextStyle(
fontSize: 16,
height: 1.5,
),
),
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 55,

child: ElevatedButton.icon(
icon: const Icon(Icons.handshake),

label: Text(
l10n.makeOffer,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

onPressed: () async {

const offerFee = 50;

final user = await _userService.getUser(
FirebaseAuth.instance.currentUser!.uid,
);

final tokenBalance = user?.tokens ?? 0;

if (tokenBalance < offerFee) {

showDialog(
context: context,

builder: (_) => AlertDialog(

title: Text(
l10n.insufficientTokens,
),

content: Text(
l10n.minimumTokensRequired,
),

actions: [

TextButton(
onPressed: () {
Navigator.pop(context);
},

child: Text(
l10n.close,
),
),

ElevatedButton(
onPressed: () {

Navigator.pop(context);

// Buraya daha sonra
// Cüzdan Sayfası gelecek.
},

child: Text(
l10n.buyTokens,
),
),
],
),
);

return;
}

Navigator.push(
context,

MaterialPageRoute(
builder: (_) => OfferPage(
job: widget.job,
),
),
);
},
),
),
],
),
),
);
}
}