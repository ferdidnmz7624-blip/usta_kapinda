import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/job_model.dart';
import '../models/offer_model.dart';
import '../models/review_model.dart';
import '../services/job_service.dart';
import '../services/offer_service.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../pages/notifications_page.dart';
import '../widgets/notification_badge.dart';
import '../pages/job_detail_page.dart';
import '../screens/offer_page.dart';
import 'package:intl/intl.dart';
import 'wallet_deposit_page.dart';
import '../generated/app_localizations.dart';

class CraftsmanHomePage extends StatefulWidget {
  const CraftsmanHomePage({super.key});

  @override
  State<CraftsmanHomePage> createState() => _CraftsmanHomePageState();
}

class _CraftsmanHomePageState extends State<CraftsmanHomePage> {
final JobService _jobService = JobService();
final OfferService _offerService = OfferService();
final NotificationService _notificationService =
NotificationService();
final UserService _userService = UserService();
final ReviewService _reviewService = ReviewService();

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  appBar: AppBar(
    title: Text(l10n.craftsmanPanel),
    actions: [
      NotificationBadge(),
    ],
  ),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

FutureBuilder<UserModel?>(
future: _userService.getUser(
FirebaseAuth.instance.currentUser!.uid,
),
builder: (context, userSnapshot) {
  final firstName =
      userSnapshot.data?.firstName ?? l10n.craftsman;

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),

decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
gradient: const LinearGradient(
colors: [
Color(0xff1565C0),
Color(0xff42A5F5),
],
),
),
  child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

  Text(
    "👷 ${l10n.hello} $firstName 👋",
    style: const TextStyle(
color: Colors.white,
fontSize: 26,
fontWeight: FontWeight.bold,
),
),

SizedBox(height: 8),

  _availableJobsSummary(l10n),

],
  ),
);
},
),
  const SizedBox(height: 25),
  FutureBuilder<UserModel?>(
    future: _userService.getUser(
      FirebaseAuth.instance.currentUser!.uid,
    ),
    builder: (context, snapshot) {

      final user = snapshot.data;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.amber,
          ),
        ),
        child: Row(
          children: [

            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.amber,
              child: Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    l10n.tokenBalance,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "🪙 ${user?.tokens ?? 0} ${l10n.tokens}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletDepositPage(),
                  ),
                );
              },
              // Bu giriş, App Review ve kullanıcılar için Jeton Mağazası
              // yönlendirmesini açıkça belirtir.
              child: Text(l10n.buyTokens),
            ),
          ],
        ),
      );
    },
  ),
Row(
children: [

  Expanded(
    child: FutureBuilder<UserModel?>(
      future: _userService.getUser(
        FirebaseAuth.instance.currentUser!.uid,
      ),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) {
          return _statCard("0", l10n.newJobs, Icons.work);
        }

        return StreamBuilder<List<JobModel>>(
          stream: _jobService.getJobsForCraftsman(
            city: user.city,
            professions: user.professions,
          ),
          builder: (context, jobSnapshot) {
            return StreamBuilder<List<OfferModel>>(
              stream: _offerService.getOffersByCraftsman(
                FirebaseAuth.instance.currentUser!.uid,
              ),
              builder: (context, offerSnapshot) {
                final count = _availableJobCount(
                  jobs: jobSnapshot.data ?? const <JobModel>[],
                  offers: offerSnapshot.data ?? const <OfferModel>[],
                );

                return _statCard(
                  count.toString(),
                  l10n.newJobs,
                  Icons.work,
                );
              },
            );
          },
        );
      },
    ),
  ),

const SizedBox(width: 12),

  Expanded(
    child: StreamBuilder<List<OfferModel>>(
      stream: _offerService.getOffersByCraftsman(
        FirebaseAuth.instance.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _statCard(
            "0",
            l10n.offers,
            Icons.handshake,
          );
        }

        return _statCard(
          snapshot.data!.length.toString(),
          l10n.offers,
          Icons.handshake,
        );
      },
    ),
  ),

],
),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: StreamBuilder<List<OfferModel>>(
          stream: _offerService.getOffersByCraftsman(
            FirebaseAuth.instance.currentUser!.uid,
          ),
          builder: (context, snapshot) {
            final acceptedCount = (snapshot.data ?? const <OfferModel>[])
                .where(
                  (offer) =>
                      offer.status != "pending" && offer.status != "rejected",
                )
                .length;

            return _statCard(
              acceptedCount.toString(),
              l10n.accepted,
              Icons.check_circle,
            );
          },
        ),
      ),

      const SizedBox(width: 12),
      Expanded(
        child: StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getUserReviews(
            FirebaseAuth.instance.currentUser!.uid,
          ),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? const <ReviewModel>[];
            final rating = reviews.isEmpty
                ? 0.0
                : reviews
                        .map((review) => review.rating)
                        .reduce((sum, rating) => sum + rating) /
                    reviews.length;

            return _statCard(
              rating.toStringAsFixed(1),
              l10n.rating,
              Icons.star,
            );
          },
        ),
      ),
    ],
  ),

  const SizedBox(height: 30),

  Text(
    l10n.latestListings,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
const SizedBox(height: 15),

FutureBuilder<UserModel?>(
future: _userService.getUser(
  FirebaseAuth.instance.currentUser!.uid,
),
builder: (context, userSnapshot) {
final user = userSnapshot.data;

if (user == null) {
  return Text(l10n.noListingsYet);
}

return StreamBuilder<List<JobModel>>(
stream: _jobService.getJobsForCraftsman(
  city: user.city,
  professions: user.professions,
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
  return Text(
    l10n.noListingsYet,
  );
}

final jobs = snapshot.data!;
return Column(
children: jobs.map((job) {

return Padding(
padding:
const EdgeInsets.only(bottom: 15),

child: _jobCard(job),

);

}).toList(),
);
},
);
},
),

],
),
),
);
}
Widget _statCard(
    String value,
    String title,
    IconData icon,
    ) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          blurRadius: 8,
          color: Colors.black12,
        )
      ],
    ),
    child: Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    ),
  );
}
Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case "tesisat":
      return Colors.blue;

    case "elektrik":
      return Colors.orange;

    case "boya":
      return Colors.amber;

    case "bahçe":
      return Colors.green;

    case "mobilya":
      return Colors.purple;

    default:
      return Colors.blueGrey;
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case "tesisat":
      return Icons.plumbing;

    case "elektrik":
      return Icons.electrical_services;

    case "boya":
      return Icons.format_paint;

    case "bahçe":
      return Icons.yard;

    case "mobilya":
      return Icons.chair;

    default:
      return Icons.home_repair_service;
  }
}
Widget _availableJobsSummary(AppLocalizations l10n) {
  return FutureBuilder<UserModel?>(
    future: _userService.getUser(FirebaseAuth.instance.currentUser!.uid),
    builder: (context, userSnapshot) {
      final user = userSnapshot.data;
      if (user == null) {
        return Text(
          l10n.noNewListingsToday,
          style: const TextStyle(color: Colors.white70),
        );
      }

      return StreamBuilder<List<JobModel>>(
        stream: _jobService.getJobsForCraftsman(
          city: user.city,
          professions: user.professions,
        ),
        builder: (context, jobSnapshot) {
          return StreamBuilder<List<OfferModel>>(
            stream: _offerService.getOffersByCraftsman(
              FirebaseAuth.instance.currentUser!.uid,
            ),
            builder: (context, offerSnapshot) {
              final count = _availableJobCount(
                jobs: jobSnapshot.data ?? const <JobModel>[],
                offers: offerSnapshot.data ?? const <OfferModel>[],
              );

              return Text(
                count == 0
                    ? l10n.noNewListingsToday
                    : l10n.newListingsWaiting(count),
                style: const TextStyle(color: Colors.white70),
              );
            },
          );
        },
      );
    },
  );
}

int _availableJobCount({
  required List<JobModel> jobs,
  required List<OfferModel> offers,
}) {
  final offeredJobIds = offers.map((offer) => offer.jobId).toSet();
  return jobs.where((job) => !offeredJobIds.contains(job.id)).length;
}
Widget _jobCard(JobModel job) {
  final l10n = AppLocalizations.of(context)!;
  final Color color = _categoryColor(job.category);
  final IconData icon = _categoryIcon(job.category);
  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ÜST KISIM
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(.15),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      job.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          "${job.city} / ${job.district}",
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

            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.estimatedBudget,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₺${NumberFormat('#,##0', 'tr_TR').format(job.budget)}",
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: Row(
            children: [

              Icon(
                Icons.info_outline,
                color: Colors.orange,
              ),

              SizedBox(width: 8),

              Expanded(
                child: Text(
                  l10n.offerFee,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {

              final user = await _userService.getUser(
                FirebaseAuth.instance.currentUser!.uid,
              );

              if (user == null || user.tokens < 50) {

                if (!mounted) return;

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
  title: Text(l10n.insufficientTokens),
  content: Text(l10n.minimumTokensRequired),
                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
  child: Text(l10n.close),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletDepositPage(),
                            ),
                          );
                        },
  child: Text(l10n.buyTokens),
                      ),

                    ],
                  ),
                );

                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferPage(job: job),
                ),
              );
            },
  child: Text(
  l10n.makeOffer,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailPage(job: job),
                ),
              );
            },
  child: Text(
  l10n.viewJobDetails,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
