import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;
  final Timestamp createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "body": body,
      "isRead": isRead,
      "createdAt": createdAt,
    };
  }

  factory NotificationModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return NotificationModel(
      id: id,
      userId: map["userId"] ?? "",
      title: map["title"] ?? "",
      body: map["body"] ?? "",
      isRead: map["isRead"] ?? false,
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}