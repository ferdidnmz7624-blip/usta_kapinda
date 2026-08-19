import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/offer_model.dart';
import '../services/job_service.dart';
import '../services/offer_service.dart';
import '../services/chat_service.dart';
import 'craftsman_review_page.dart';
import '../pages/chat_page.dart';
import '../generated/app_localizations.dart';

class CraftsmanOffersPage extends StatefulWidget {
  const CraftsmanOffersPage({super.key});

  @override
  State<CraftsmanOffersPage> createState() =>
      _CraftsmanOffersPageState();
}

class _CraftsmanOffersPageState
    extends State<CraftsmanOffersPage>
    with SingleTickerProviderStateMixin {

final OfferService _offerService = OfferService();
final JobService _jobService = JobService();
final ChatService _chatService = ChatService();

late TabController _tabController;

@override
void initState() {
super.initState();

_tabController = TabController(
length: 5,
vsync: this,
);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}

Color statusColor(String status) {
switch (status) {
case "pending":
return Colors.orange;

case "accepted":
return Colors.green;

case "rejected":
return Colors.red;

case "in_progress":
return Colors.blue;

case "completed":
return Colors.deepPurple;

default:
return Colors.grey;
}
}

String statusText(String status, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  switch (status) {
    case "pending":
      return l10n.pending;

    case "accepted":
      return l10n.acceptedStatus;

    case "rejected":
      return l10n.rejected;

    case "in_progress":
      return l10n.inProgress;

    case "completed":
      return l10n.completed;

    default:
      return "";
  }
}

IconData statusIcon(String status) {
switch (status) {
case "pending":
return Icons.schedule;

case "accepted":
return Icons.check_circle;

case "rejected":
return Icons.cancel;

case "in_progress":
return Icons.handyman;

case "completed":
return Icons.task_alt;

default:
return Icons.info;
}
}

Widget buildStatusChip(String status) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 7,
),
decoration: BoxDecoration(
color: statusColor(status).withOpacity(.12),
borderRadius: BorderRadius.circular(30),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [

Icon(
statusIcon(status),
size: 18,
color: statusColor(status),
),

const SizedBox(width: 6),

Text(
  statusText(status, context),
style: TextStyle(
color: statusColor(status),
fontWeight: FontWeight.bold,
),
),
],
),
);
}

Widget _offerList() {
return StreamBuilder<List<OfferModel>>(
  stream: _offerService.getOffersByCraftsman(
    FirebaseAuth.instance.currentUser!.uid,
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
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [

Icon(
Icons.work_outline,
size: 80,
color: Colors.grey.shade400,
),

const SizedBox(height: 20),

  Text(
    AppLocalizations.of(context)!.noOffersYet,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 17,
),
),
],
),
);
}

final offers = snapshot.data!;

return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: offers.length,
itemBuilder: (context, index) {

final offer = offers[index];

// PARÇA 2 BURADAN DEVAM EDECEK
return Container(
margin: const EdgeInsets.only(bottom: 18),
child: Material(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
elevation: 4,
shadowColor: Colors.black12,
child: InkWell(
borderRadius: BorderRadius.circular(22),
onTap: () {},
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

Container(
height: 58,
width: 58,
decoration: BoxDecoration(
color: Colors.blue.shade50,
borderRadius: BorderRadius.circular(16),
),
child: const Icon(
Icons.handyman,
color: Colors.blue,
size: 30,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
offer.jobTitle,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

  Text(
    AppLocalizations.of(context)!.jobListing,
style: TextStyle(
color: Colors.grey.shade600,
),
),
],
),
),

  buildStatusChip(offer.status),
],
),

const SizedBox(height: 22),

Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius:
BorderRadius.circular(18),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

  Text(
    AppLocalizations.of(context)!.myOffer,
style: TextStyle(
color: Colors.grey.shade700,
),
),

const SizedBox(height: 6),

Text(
"₺${offer.price.toStringAsFixed(0)}",
style: const TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: Colors.blue,
),
),
],
),
),

const SizedBox(height: 18),

Row(
children: [

Icon(
Icons.calendar_today,
size: 18,
color: Colors.grey.shade600,
),

const SizedBox(width: 8),

  Text(
    AppLocalizations.of(context)!.offerSent,
style: TextStyle(
color: Colors.grey.shade700,
),
),
],
),

const SizedBox(height: 22),

Divider(color: Colors.grey.shade300),

const SizedBox(height: 18),
  if (offer.status == "pending")
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.waitingForCustomerApproval,
            ),
          ),
        ],
      ),
    ),

  if (offer.status == "accepted")
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          await _offerService.updateOfferStatus(
            offerId: offer.id,
            status: "in_progress",
          );

          await _jobService.updateJobStatus(
            jobId: offer.jobId,
            status: "in_progress",
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(
          AppLocalizations.of(context)!.startJob,
        ),
      ),
    ),
  if (offer.status == "accepted")
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
            await _offerService.updateOfferStatus(
              offerId: offer.id,
              status: "cancelled",
            );

            await _jobService.updateJobStatus(
              jobId: offer.jobId,
              status: "cancelled",
            );


          },
          icon: const Icon(Icons.cancel),
          label: Text(
            AppLocalizations.of(context)!.cancelJob,
          ),
        ),
      ),
    ),
  if (offer.status == "cancelled")
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.jobCancelled,
            ),
          ),
        ],
      ),
    ),
  if (offer.status == "rejected")
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.offerRejected,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),

  if (offer.status == "in_progress")
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          await _offerService.updateOfferStatus(
            offerId: offer.id,
            status: "completed",
          );

          await _jobService.updateJobStatus(
            jobId: offer.jobId,
            status: "completed",
          );
          await _chatService.deleteChatByJobId(
            offer.jobId,
          );
        },
        icon: const Icon(Icons.task_alt),
        label: Text(
          AppLocalizations.of(context)!.completeJob,
        ),
      ),
    ),
  if (offer.status == "in_progress")
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {

            final chatId =
            await _chatService.openChatForOffer(
              offerId: offer.id,
            );

            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  chatId: chatId,
                  receiverId: offer.customerId,
  receiverName: AppLocalizations.of(context)!.customer,
                ),
              ),
            );

            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  chatId: chatId,
                  receiverId: offer.customerId,
  receiverName: AppLocalizations.of(context)!.customer,
                ),
              ),
            );

          },
          icon: const Icon(Icons.chat),
  label: Text(
  AppLocalizations.of(context)!.sendMessageToCustomer,
  ),
        ),
      ),
    ),
  if (offer.status == "in_progress")
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
            await _offerService.updateOfferStatus(
              offerId: offer.id,
              status: "cancelled",
            );

            await _jobService.updateJobStatus(
              jobId: offer.jobId,
              status: "cancelled",
            );

            await _chatService.deleteChatByJobId(offer.jobId);
          },
          icon: const Icon(Icons.cancel),
          label: Text(
            AppLocalizations.of(context)!.cancelJob,
          ),
        ),
      ),
    ),
  if (offer.status == "completed" &&
  !offer.craftsmanReviewed) ...[
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async{
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CraftsmanReviewPage(
                customerId: offer.customerId,
                jobId: offer.jobId,
              ),
            ),
          );

          await _offerService.markCraftsmanReviewed(
            offer.id,
          );


        },
        icon: const Icon(Icons.star),
  label: Text(
  AppLocalizations.of(context)!.reviewCustomer,
  ),
      ),
    ),
  ],

  if (offer.craftsmanReviewed) ...[
  Container(
  width: double.infinity,
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
  color: Colors.orange.shade100,
  borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  Icon(Icons.star, color: Colors.orange),
  SizedBox(width: 8),
  Text(
  AppLocalizations.of(context)!.customerReviewed,
  style: TextStyle(
  color: Colors.orange,
  fontWeight: FontWeight.bold,
  ),
  ),
  ],
  ),
  ),
  ],

],

),
),
),
),
);
},
);
},
);
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xffF5F7FA),
    appBar: AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.blue,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        AppLocalizations.of(context)!.myOffers,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

    ),
    body: _offerList(),
  );
}
}