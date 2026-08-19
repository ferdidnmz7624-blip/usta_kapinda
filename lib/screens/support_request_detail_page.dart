import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../generated/app_localizations.dart';

class SupportRequestDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const SupportRequestDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection("support_requests")
.where("ticketNo", isEqualTo: data["ticketNo"])
.limit(1)
.snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Scaffold(
body: Center(
child: CircularProgressIndicator(),
),
);
}

if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  return Scaffold(
    body: Center(
      child: Text(l10n.supportRequestNotFound),
    ),
  );
}

final support =
snapshot.data!.docs.first.data() as Map<String, dynamic>;

return Scaffold(
  appBar: AppBar(
    title: Text(l10n.supportRequest),
  ),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
support["subject"] ?? "",
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

  Text(
    "${l10n.ticketNumber}: ${support["ticketNo"]}",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),

const SizedBox(height: 20),

  Text(
    l10n.description,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),

const SizedBox(height: 8),

Text(support["description"] ?? ""),

const SizedBox(height: 30),

if ((support["adminReply"] ?? "").toString().isNotEmpty)
Card(
color: Colors.green.shade50,
child: Padding(
padding: const EdgeInsets.all(15),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
  Text(
    l10n.supportTeam,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
const SizedBox(height: 8),
Text(support["adminReply"]),
],
),
),
),
],
),
),
);
},
);
}
}
