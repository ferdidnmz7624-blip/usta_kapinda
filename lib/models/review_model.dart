import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String customerId;
  final String craftsmanId;
  final String jobId;
  final String reviewerType;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.customerId,
    required this.craftsmanId,
    required this.jobId,
    required this.reviewerType,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "customerId": customerId,
      "craftsmanId": craftsmanId,
      "jobId": jobId,
      "reviewerType": reviewerType,

      "reviewerId": reviewerType == "customer"
          ? customerId
          : craftsmanId,

      "rating": rating,
      "comment": comment,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    final createdAt = map["createdAt"];

    return ReviewModel(
      id: id,
      customerId: map["customerId"],
      craftsmanId: map["craftsmanId"],
      jobId: map["jobId"],
      reviewerType: map["reviewerType"] ?? "customer",
      rating: (map["rating"] as num).toDouble(),
      comment: map["comment"] ?? "",
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
