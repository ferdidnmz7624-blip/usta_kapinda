
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../generated/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
NotificationsPage({super.key});

final NotificationService _notificationService =
NotificationService();

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
return Scaffold(
body: Center(
child: Text(l10n.sessionNotFound),
),
);
}

return Scaffold(
appBar: AppBar(
title: Text(l10n.notifications),
centerTitle: true,
),
body: StreamBuilder<List<NotificationModel>>(
stream: _notificationService.getNotifications(user.uid),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final notifications = snapshot.data ?? [];

if (notifications.isEmpty) {
return Center(
child: Text(l10n.noNotifications),
);
}

return ListView.builder(
itemCount: notifications.length,
itemBuilder: (context, index) {
final notification = notifications[index];

return ListTile(
leading: CircleAvatar(
backgroundColor: notification.isRead
? Colors.grey.shade300
    : Colors.blue,
child: Icon(
notification.isRead
? Icons.notifications_none
    : Icons.notifications,
color: Colors.white,
),
),
title: Text(notification.title),
subtitle: Text(notification.body),
onTap: () async {
if (!notification.isRead) {
await _notificationService.markAsRead(
notification.id,
);
}
},
);
},
);
},
),
);
}
}