import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../pages/job_detail_page.dart';
import '../pages/offers_page.dart';
import '../services/job_service.dart';
import '../generated/app_localizations.dart';

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
final JobService _jobService = JobService();

int selectedIndex = 0;

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final user = FirebaseAuth.instance.currentUser!;

return Scaffold(
appBar: AppBar(
  title: Text(l10n.myListings),
centerTitle: true,
),
body: Column(
children: [
Padding(
padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
child: Row(
children: [
Expanded(
child: InkWell(
borderRadius: BorderRadius.circular(15),
onTap: () {
setState(() {
selectedIndex = 0;
});
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 250),
height: 55,
decoration: BoxDecoration(
color: Colors.orange,
borderRadius: BorderRadius.circular(15),
boxShadow: [
if (selectedIndex == 0)
BoxShadow(
color: Colors.orange.withOpacity(.35),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.work, color: Colors.white),
SizedBox(width: 8),
  Text(
    l10n.myListings,
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
),
const SizedBox(width: 12),
Expanded(
child: InkWell(
borderRadius: BorderRadius.circular(15),
onTap: () {
setState(() {
selectedIndex = 1;
});
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 250),
height: 55,
decoration: BoxDecoration(
color: Colors.green,
borderRadius: BorderRadius.circular(15),
boxShadow: [
if (selectedIndex == 1)
BoxShadow(
color: Colors.green.withOpacity(.35),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.local_offer, color: Colors.white),
SizedBox(width: 8),
Flexible(
child: Text(
  l10n.newIncomingOffers,
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),
],
),
),
),
),
],
),
),

Expanded(
child: IndexedStack(
index: selectedIndex,
children: [
StreamBuilder<List<JobModel>>(
stream: _jobService.getUserJobs(user.uid),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(snapshot.error.toString()),
);
}

final jobs = snapshot.data ?? [];

if (jobs.isEmpty) {
  return Center(
    child: Text(l10n.noMyListings),
  );
}

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: jobs.length,
itemBuilder: (context, index) {
final job = jobs[index];

return Card(
elevation: 3,
margin: const EdgeInsets.only(bottom: 16),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
child: InkWell(
borderRadius:
BorderRadius.circular(15),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
JobDetailPage(job: job),
),
);
},
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
job.title,
style: const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(job.description),

const SizedBox(height: 15),

Wrap(
spacing: 8,
runSpacing: 8,
children: [
Chip(
avatar: const Icon(
Icons.category,
size: 18),
label:
Text(job.category),
),
Chip(
avatar: const Icon(
Icons.location_city,
size: 18),
label:
Text(job.city),
),
Chip(
avatar: const Icon(
Icons.map,
size: 18),
label: Text(
job.district),
),
],
),

const SizedBox(height: 15),

Row(
mainAxisAlignment:
MainAxisAlignment
.spaceBetween,
children: [
Text(
"₺${job.budget.toStringAsFixed(0)}",
style:
const TextStyle(
color: Colors.green,
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

Chip(
backgroundColor:
job.status ==
"active"
? Colors.green
.shade100
: Colors.red
.shade100,
avatar: Icon(
job.status ==
"active"
? Icons
.check_circle
: Icons.cancel,
color: job.status ==
"active"
? Colors.green
: Colors.red,
),
label: Text(
job.status ==
"active"
    ? l10n.published
    : l10n.removed,
  style: TextStyle(
    color: job.status == "active"
        ? Colors.green.shade800
        : Colors.red.shade800,
    fontWeight: FontWeight.bold,
  ),
),
),
],
),

  const SizedBox(height: 15),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        job.status == "active"
            ? Colors.red
            : Colors.green,
        foregroundColor: Colors.white,
      ),
      icon: Icon(
        job.status == "active"
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      label: Text(
        job.status == "active"
            ? l10n.removeListing
            : l10n.republishListing,
      ),
      onPressed: () async {
        if (job.status == "active") {
          await _jobService.closeJob(job.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  l10n.listingRemoved,
                ),
              ),
            );
          }
        } else {
          await _jobService.openJob(job.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  l10n.listingRepublished,
                ),
              ),
            );
          }
        }
      },
    ),
  ),
],
),
),
),
);
},
);
},
),

  const OffersPage(),
],
),
),
],
),
);
}
}