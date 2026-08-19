import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';
import '../generated/app_localizations.dart';

class CraftsmanReviewPage extends StatefulWidget {
  final String customerId;
  final String jobId;

  const CraftsmanReviewPage({
    super.key,
    required this.customerId,
    required this.jobId,
  });

  @override
  State<CraftsmanReviewPage> createState() =>
      _CraftsmanReviewPageState();
}

class _CraftsmanReviewPageState extends State<CraftsmanReviewPage> {
  final ReviewService _reviewService = ReviewService();

  final TextEditingController _commentController =
  TextEditingController();

  double _rating = 5;
  bool _loading = false;

  Future<void> submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseWriteComment,
          ),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final review = ReviewModel(
      id: "",
      customerId: widget.customerId,
      craftsmanId: currentUser.uid,
      jobId: widget.jobId,
      reviewerType: "craftsman",
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _reviewService.addReview(review);

    if (!mounted) return;

    print("POP ÇALIŞTI");

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.reviewSubmittedSuccessfully,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.reviewCustomer,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.score,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

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
              AppLocalizations.of(context)!
                  .stars(_rating.toInt()),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.yourComment,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : submitReview,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(
                  AppLocalizations.of(context)!.submitReview,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}