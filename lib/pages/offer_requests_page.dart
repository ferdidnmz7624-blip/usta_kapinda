
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/offer_model.dart';
import '../services/offer_service.dart';
import '../generated/app_localizations.dart';

class OfferRequestsPage extends StatelessWidget {
OfferRequestsPage({super.key});

final OfferService _offerService = OfferService();

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;
final user = FirebaseAuth.instance.currentUser!;

return StreamBuilder<List<OfferModel>>(
stream: _offerService.getOffersByCustomer(user.uid),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(snapshot.error.toString()),
);
}

final offers = snapshot.data ?? [];

final waitingOffers = offers
    .where((e) => e.status == "pending")
    .toList();

if (waitingOffers.isEmpty) {
return Center(
child: Text(
l10n.newOffers,
style: const TextStyle(fontSize: 18),
),
);
}

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: waitingOffers.length,
itemBuilder: (context, index) {
final offer = waitingOffers[index];

return Card(
margin: const EdgeInsets.only(bottom: 16),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
offer.jobTitle,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(
"${l10n.offer}: ₺${offer.price.toStringAsFixed(0)}",
),

const SizedBox(height: 5),

Text(
"${l10n.duration}: ${offer.estimatedDays} ${l10n.days}",
),

const SizedBox(height: 10),

Text(offer.message),

const SizedBox(height: 20),

Row(
children: [
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
),
onPressed: () async {
await _offerService.acceptOffer(
offer.id,
);

if (context.mounted) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
l10n.offerAccepted,
),
),
);
}
},
child: Text(l10n.accept),
),
),

const SizedBox(width: 10),

Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
),
onPressed: () async {
await _offerService.rejectOffer(
offer.id,
);

if (context.mounted) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
l10n.offerRejected,
),
),
);
}
},
child: Text(l10n.reject),
),
),
],
),
],
),
),
);
},
);
},
);
}
}