import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserStatistics(
      String userId,
      ) async {
    final userDoc =
    await _firestore.collection("users").doc(userId).get();

    final reviews = await _firestore
        .collection("reviews")
        .where("craftsmanId", isEqualTo: userId)
        .get();

    double rating = 0;

    if (reviews.docs.isNotEmpty) {
      rating = reviews.docs
          .map((e) => (e["rating"] as num).toDouble())
          .reduce((a, b) => a + b) /
          reviews.docs.length;
    } else {
      rating =
          (userDoc.data()?["rating"] ?? 0).toDouble();
    }

    final completed =
        userDoc.data()?["completedJobs"] ?? 0;

    final success =
    completed == 0 ? 0 : ((rating / 5) * 100).round();

    return {
      "rating": rating,
      "reviewCount": reviews.docs.length,
      "completedJobs": completed,
      "successRate": success,
    };
  }
}