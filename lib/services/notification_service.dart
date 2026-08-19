import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    final doc = _firestore.collection("notifications").doc();

    final notification = NotificationModel(
      id: doc.id,
      userId: userId,
      title: title,
      body: body,
      isRead: false,
      createdAt: Timestamp.now(),
    );

    await doc.set(notification.toMap());
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection("notifications")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => NotificationModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection("notifications")
        .doc(notificationId)
        .update({
      "isRead": true,
    });
  }
  Future<List<UserModel>> getMatchingCraftsmen(JobModel job) async {
    final snapshot = await _firestore
        .collection("users")
        .where("accountType", isEqualTo: "craftsman")
        .where("city", isEqualTo: job.city)
        .get();

    List<UserModel> result = [];

    for (var doc in snapshot.docs) {
      final craftsman = UserModel.fromMap(doc.data());

      if (craftsman.professions.contains(job.category)) {
        result.add(craftsman);
      }
    }

    return result;
  }
}