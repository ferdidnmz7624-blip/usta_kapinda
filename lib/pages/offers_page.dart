
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/offer_model.dart';

import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/offer_service.dart';

import 'chat_page.dart';
import 'review_page.dart';

import '../generated/app_localizations.dart';

class OffersPage extends StatefulWidget {
const OffersPage({super.key});

@override
State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
final OfferService _offerService = OfferService();
final ChatService _chatService = ChatService();
final NotificationService _notificationService =
NotificationService();

String? _loadingAcceptOfferId;
String? _loadingProgressOfferId;

@override
void initState() {
super.initState();

_offerService.markAllOffersAsSeen(
FirebaseAuth.instance.currentUser!.uid,
);
}

Future<bool> _changeOfferStatus({
required String offerId,
required String status,
}) async {
try {
await _offerService.updateOfferStatus(
offerId: offerId,
status: status,
);
return true;
} catch (_) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("İşlem tamamlanamadı. Lütfen tekrar deneyin."),
),
);
}
return false;
}
}

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;
final currentUser = FirebaseAuth.instance.currentUser;

if (currentUser == null) {
return Scaffold(
body: Center(
child: Text(l10n.sessionNotFound),
),
);
}

return Scaffold(
appBar: AppBar(
title: Text(l10n.incomingOffers),
centerTitle: true,
),
body: StreamBuilder<List<OfferModel>>(
stream: _offerService.getOffersByCustomer(
currentUser.uid,
),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return Center(
child: Text(
l10n.noIncomingOffers,
),
);
}

final offers = snapshot.data!;

return ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: offers.length,
itemBuilder: (context, index) {
final offer = offers[index];

Color statusColor = Colors.orange;
String statusText = l10n.pending;

switch (offer.status) {
case "accepted":
statusColor = Colors.green;
statusText = l10n.accepted;
break;

case "rejected":
statusColor = Colors.red;
statusText = l10n.rejected;
break;

case "in_progress":
statusColor = Colors.blue;
statusText = l10n.inProgress;
break;

case "completed":
statusColor = Colors.purple;
statusText = l10n.completed;
break;

case "reviewed":
statusColor = Colors.orange;
statusText = l10n.reviewed;
break;

case "cancelled":
statusColor = Colors.grey;
statusText = l10n.cancelled;
break;
}

return Card(
elevation: 4,
margin:
const EdgeInsets.only(bottom: 15),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(
Icons.handyman,
color: Colors.blue,
),

const SizedBox(width: 10),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
l10n.craftsmanOffer,
style: const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
offer.jobTitle,
style:
const TextStyle(
color:
Colors.black54,
),
),
],
),
),

Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color: statusColor,
borderRadius:
BorderRadius
    .circular(20),
),
child: Text(
statusText,
style:
const TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
),
),
),
],
),

const SizedBox(height: 20),

Text(
"💰 ${l10n.offerPrice}",
style: TextStyle(
color:
Colors.grey.shade700,
),
),

const SizedBox(height: 5),

Text(
"₺${offer.price.toStringAsFixed(0)}",
style:
const TextStyle(
fontSize: 28,
fontWeight:
FontWeight.bold,
color: Colors.green,
),
),

const SizedBox(height: 20),

Text(
"📝 ${l10n.description}",
style: TextStyle(
color:
Colors.grey.shade700,
),
),

const SizedBox(height: 5),

Text(
offer.message,
style:
const TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 20),

Text(
"⏳ ${l10n.estimatedDuration}",
style: TextStyle(
color:
Colors.grey.shade700,
),
),

const SizedBox(height: 5),

Text(
"${offer.estimatedDays} ${l10n.days}",
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 25),

if (offer.status == "pending") ...[
Row(
children: [
Expanded(
child: ElevatedButton(
onPressed:
_loadingAcceptOfferId ==
offer.id
? null
    : () async {
setState(() {
_loadingAcceptOfferId =
offer.id;
});

try {
await _offerService
    .acceptOffer(
offer.id,
);

await _notificationService
    .createNotification(
userId:
offer.craftsmanId,
title:
l10n.offerAcceptedTitle,
body:
"'${offer.jobTitle}' ${l10n.offerAcceptedBody}",
);

if (!mounted) {
return;
}

ScaffoldMessenger
    .of(context)
    .showSnackBar(
SnackBar(
content:
Text(
l10n.offerAccepted,
),
),
);
} finally {
if (mounted) {
setState(() {
_loadingAcceptOfferId =
null;
});
}
}
},
style:
ElevatedButton
    .styleFrom(
backgroundColor:
Colors.green,
foregroundColor:
Colors.white,
),
child:
_loadingAcceptOfferId ==
offer.id
? const SizedBox(
height: 22,
child:
FittedBox(
fit: BoxFit
    .scaleDown,
child: Row(
mainAxisSize:
MainAxisSize
    .min,
children: [
SizedBox(
width: 14,
height: 14,
child:
CircularProgressIndicator(
strokeWidth:
2,
color: Colors
    .white,
),
),
SizedBox(
width: 6,
),
Text(
"Kabul Ediliyor...",
),
],
),
),
)
    : Row(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
const Icon(
Icons.check,
),
const SizedBox(
width: 6,
),
Text(
l10n.accept,
),
],
),
),
),

const SizedBox(width: 12),

Expanded(
child:
ElevatedButton.icon(
icon: const Icon(
Icons.close,
),
label: Text(
l10n.reject,
),
style:
ElevatedButton
    .styleFrom(
backgroundColor:
Colors.red,
foregroundColor:
Colors.white,
),
onPressed: () async {
await _offerService
    .rejectOffer(
offer.id,
);

await _notificationService
    .createNotification(
userId:
offer.craftsmanId,
title:
l10n.offerRejectedTitle,
body:
"'${offer.jobTitle}' ${l10n.offerRejectedBody}",
);

if (!mounted) {
return;
}

ScaffoldMessenger
    .of(context)
    .showSnackBar(
SnackBar(
content: Text(
l10n.offerRejected,
),
),
);
},
),
),
],
),
],

if (offer.status == "accepted") ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:
Colors.green.shade100,
borderRadius:
BorderRadius.circular(10),
),
child: Center(
child: Text(
"✅ ${l10n.offerAcceptedStatus}",
style:
const TextStyle(
color: Colors.green,
fontWeight:
FontWeight.bold,
),
),
),
),

const SizedBox(height: 12),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon:
_loadingProgressOfferId ==
offer.id
? const SizedBox(
width: 18,
height: 18,
child:
CircularProgressIndicator(
strokeWidth: 2,
color:
Colors.white,
),
)
    : const Icon(
Icons.work,
),
label: Text(
_loadingProgressOfferId ==
offer.id
? l10n.loading
    : l10n.workingWithCraftsman,
),
onPressed:
_loadingProgressOfferId ==
offer.id
? null
    : () async {
setState(() {
_loadingProgressOfferId =
offer.id;
});

try {
final changed = await _changeOfferStatus(
offerId: offer.id,
status: "in_progress",
);

if (!changed) return;

if (!mounted) {
return;
}

ScaffoldMessenger
    .of(context)
    .showSnackBar(
SnackBar(
content:
Text(
l10n.jobInProgressUpdated,
),
),
);
} finally {
if (mounted) {
setState(() {
_loadingProgressOfferId =
null;
});
}
}
},
),
),
],

if (offer.status == "accepted") ...[
const SizedBox(height: 10),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon: const Icon(
Icons.cancel,
),
label: Text(
l10n.cancelJob,
),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.red,
foregroundColor:
Colors.white,
),
onPressed: () async {
await _changeOfferStatus(
offerId: offer.id,
status: "cancelled",
);

},
),
),
],

if (offer.status == "in_progress") ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:
Colors.blue.shade100,
borderRadius:
BorderRadius.circular(10),
),
child: Center(
child: Text(
"🛠 ${l10n.jobInProgress}",
style:
const TextStyle(
color: Colors.blue,
fontWeight:
FontWeight.bold,
),
),
),
),

const SizedBox(height: 10),

SizedBox(
width: double.infinity,
child:
OutlinedButton.icon(
icon: const Icon(
Icons.message,
),
label: Text(
l10n.sendMessage,
),
onPressed: () async {
final chatId =
await _chatService
    .openChatForOffer(
offerId: offer.id,
);

if (!mounted) return;

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
ChatPage(
chatId: chatId,
receiverId:
offer.craftsmanId,
receiverName:
l10n.craftsman,
),
),
);
},
),
),

const SizedBox(height: 10),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon: const Icon(
Icons.check_circle,
),
label: Text(
l10n.completeJob,
),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green,
foregroundColor:
Colors.white,
),
onPressed: () async {
final changed = await _changeOfferStatus(
offerId: offer.id,
status: "completed",
);

if (!changed) return;

if (!mounted) return;

ScaffoldMessenger
    .of(context)
    .showSnackBar(
SnackBar(
content: Text(
l10n.jobCompleted,
),
),
);
},
),
),

const SizedBox(height: 10),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon: const Icon(
Icons.cancel,
),
label: Text(
l10n.cancelJob,
),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.red,
foregroundColor:
Colors.white,
),
onPressed: () async {
await _changeOfferStatus(
offerId: offer.id,
status: "cancelled",
);

},
),
),
],

if (offer.status == "completed" &&
!offer.customerReviewed) ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:
Colors.purple.shade100,
borderRadius:
BorderRadius.circular(10),
),
child: Center(
child: Text(
"🎉 ${l10n.jobCompletedStatus}",
style:
const TextStyle(
color: Colors.purple,
fontWeight:
FontWeight.bold,
),
),
),
),

const SizedBox(height: 12),

SizedBox(
width: double.infinity,
child:
OutlinedButton.icon(
icon: const Icon(
Icons.message,
),
label: Text(
l10n.sendMessage,
),
onPressed: () async {
final chatId =
await _chatService
    .openChatForOffer(
offerId: offer.id,
);

if (!mounted) return;

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
ChatPage(
chatId: chatId,
receiverId:
offer.craftsmanId,
receiverName:
l10n.craftsman,
),
),
);
},
),
),

const SizedBox(height: 10),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon: const Icon(
Icons.star,
),
label: Text(
l10n.reviewCraftsman,
),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.orange,
foregroundColor:
Colors.white,
),
onPressed: () async {
final reviewed = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) =>
ReviewPage(
craftsmanId:
offer.craftsmanId,
jobId:
offer.jobId,
),
),
);

if (reviewed == true) {
  await _offerService.markCustomerReviewed(offer.id);
}
},
),
),
],

if (offer.customerReviewed) ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(15),
decoration:
BoxDecoration(
color:
Colors.orange.shade100,
borderRadius:
BorderRadius.circular(10),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
const Icon(
Icons.star,
color: Colors.orange,
),
const SizedBox(width: 8),
Text(
l10n.craftsmanReviewed,
style:
const TextStyle(
color: Colors.orange,
fontWeight:
FontWeight.bold,
),
),
],
),
),
],

if (offer.status == "rejected") ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:
Colors.red.shade100,
borderRadius:
BorderRadius.circular(10),
),
child: Center(
child: Text(
"❌ ${l10n.offerRejectedStatus}",
style:
const TextStyle(
color: Colors.red,
fontWeight:
FontWeight.bold,
),
),
),
),
],

if (offer.status == "cancelled") ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:
Colors.grey.shade300,
borderRadius:
BorderRadius.circular(10),
),
child: Center(
child: Text(
"🚫 ${l10n.offerCancelledStatus}",
style:
const TextStyle(
color: Colors.black54,
fontWeight:
FontWeight.bold,
),
),
),
),
],
],
),
),
);
},
);
},
),
);
}
}
