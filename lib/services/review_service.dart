import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  final String _collection = "reviews";

  Future<void> addReview(ReviewModel review) async {
    await _functions.httpsCallable('submitReview').call({
      'jobId': review.jobId,
      'reviewerType': review.reviewerType,
      'rating': review.rating,
      'comment': review.comment,
    });
  }

  Stream<List<ReviewModel>> getCraftsmanReviews(
      String craftsmanId,
      ) {
    return _firestore
        .collection(_collection)
        .where("craftsmanId", isEqualTo: craftsmanId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ReviewModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList(),
    );
  }
}
