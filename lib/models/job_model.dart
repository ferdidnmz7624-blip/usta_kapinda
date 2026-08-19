import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String city;
  final String district;
  final double budget;
  final String status;
  final int startAfterDays;
  final Timestamp createdAt;

  JobModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.district,
    required this.budget,
    required this.status,
    required this.startAfterDays,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "category": category,
      "city": city,
      "district": district,
      "budget": budget,
      "status": status,
      "startAfterDays": startAfterDays,
      "createdAt": createdAt,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map["id"],
      userId: map["userId"],
      title: map["title"],
      description: map["description"],
      category: map["category"],
      city: map["city"],
      district: map["district"],
      budget: (map["budget"] as num).toDouble(),
      status: map["status"],
      startAfterDays: map["startAfterDays"] ?? 1,
      createdAt: map["createdAt"],
    );
  }
}
