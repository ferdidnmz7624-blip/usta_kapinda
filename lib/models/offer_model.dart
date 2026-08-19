import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String jobId;
  final String customerId;
  final String craftsmanId;
  final double price;
  final String message;
  final int estimatedDays;
  final String status;
  final Timestamp createdAt;
  final bool customerReviewed;
  final bool craftsmanReviewed;
  final String jobTitle;
  final bool isSeenByCustomer;

  OfferModel({
    required this.id,
    required this.jobId,
    required this.customerId,
    required this.jobTitle,
    required this.craftsmanId,
    required this.isSeenByCustomer,
    required this.price,
    required this.message,
    required this.estimatedDays,
    required this.status,
    required this.customerReviewed,
    required this.craftsmanReviewed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "jobId": jobId,
      "customerId": customerId,
      "craftsmanId": craftsmanId,
      "price": price,
      "message": message,
      "estimatedDays": estimatedDays,

      "status": status,
      "createdAt": createdAt,
      "jobTitle": jobTitle,
      "customerReviewed": customerReviewed,
      "craftsmanReviewed": craftsmanReviewed,
      "isSeenByCustomer": isSeenByCustomer,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map["id"],
      jobId: map["jobId"],
      customerId: map["customerId"],
      craftsmanId: map["craftsmanId"],
      price: (map["price"] as num).toDouble(),
      message: map["message"],
      estimatedDays: map["estimatedDays"],

      status: map["status"],
      createdAt: map["createdAt"],
      jobTitle: map["jobTitle"],
      customerReviewed: map["customerReviewed"] ?? false,
      craftsmanReviewed: map["craftsmanReviewed"] ?? false,
      isSeenByCustomer: map["isSeenByCustomer"] ?? false,
    );
  }
}