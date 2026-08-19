
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';
import '../generated/app_localizations.dart';

class ReviewPage extends StatefulWidget {
final String craftsmanId;
final String jobId;

const ReviewPage({
super.key,
required this.craftsmanId,
required this.jobId,
});

@override
State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
final ReviewService _reviewService = ReviewService();

final TextEditingController _commentController =
TextEditingController();

double _rating = 5;

Future<void> saveReview() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) return;

final review = ReviewModel(
id: "",
customerId: user.uid,
craftsmanId: widget.craftsmanId,
jobId: widget.jobId,
reviewerType: "customer",
rating: _rating,
comment: _commentController.text.trim(),
createdAt: DateTime.now(),
);

await _reviewService.addReview(review);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
AppLocalizations.of(context)!.reviewSaved,
),
),
);

if (!mounted) return;

Navigator.of(context).pop(true);
}

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;

return Scaffold(
appBar: AppBar(
title: Text(l10n.reviewCraftsman),
),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Text(
l10n.ratingQuestion,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

Slider(
value: _rating,
min: 1,
max: 5,
divisions: 4,
label: _rating.toString(),
onChanged: (value) {
setState(() {
_rating = value;
});
},
),

Text(
"${_rating.toInt()} ⭐",
style: const TextStyle(fontSize: 22),
),

const SizedBox(height: 25),

TextField(
controller: _commentController,
maxLines: 5,
decoration: InputDecoration(
hintText: l10n.writeComment,
border: const OutlineInputBorder(),
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: saveReview,
child: Text(l10n.submitReview),
),
),
],
),
),
);
}
}