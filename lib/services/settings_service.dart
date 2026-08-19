import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/settings_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<SettingsModel> getSettings() async {
    final doc =
    await _firestore.collection("user_settings").doc(uid).get();

    if (!doc.exists) {
      final settings = SettingsModel(
        messageNotification: true,
        offerNotification: true,
        jobNotification: true,
        campaignNotification: true,
        darkMode: false,
      );

      await _firestore
          .collection("user_settings")
          .doc(uid)
          .set(settings.toMap());

      return settings;
    }

    return SettingsModel.fromMap(doc.data());
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _firestore
        .collection("user_settings")
        .doc(uid)
        .set(settings.toMap());
  }
}