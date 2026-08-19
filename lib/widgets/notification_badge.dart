import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../pages/notifications_page.dart';
import '../services/notification_service.dart';

class NotificationBadge extends StatelessWidget {
  NotificationBadge({super.key});

  final NotificationService _notificationService =
  NotificationService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Icon(Icons.notifications_none);
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getNotifications(user.uid),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];

        final unreadCount = notifications
            .where((e) => !e.isRead)
            .length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    unreadCount > 99
                        ? "99+"
                        : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}