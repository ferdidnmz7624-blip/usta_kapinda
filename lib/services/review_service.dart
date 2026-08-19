import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = "reviews";

  Future<void> addReview(ReviewModel review) async {
    final doc = _firestore.collection(_collection).doc();

    final data = {
      "id": doc.id,
      ...review.toMap(),
    };

    // Ana reviews koleksiyonuna kaydet
    await doc.set(data);

    final customerDoc = await _firestore
        .collection("users")
        .doc(review.customerId)
        .get();

    final customerData = customerDoc.data() ?? {};

    final firstName = customerData["firstName"] ?? "";
    final lastName = customerData["lastName"] ?? "";

    final photo = customerData["profilePhoto"] ?? "";

    final targetUserId =
    review.reviewerType == "customer"
        ? review.craftsmanId
        : review.customerId;

    await _firestore
        .collection("users")
        .doc(targetUserId)
        .collection("reviews")
        .doc(doc.id)
        .set({
      ...data,
      "userName": "$firstName $lastName",
      "userPhoto": photo,
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