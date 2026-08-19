import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'offer_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(
    region: "europe-west1",
  );
  Future<String> openChatForOffer({
    required String offerId,
  }) async {
    final result = await _functions
        .httpsCallable("openChatForOffer")
        .call({
      "offerId": offerId,
    });

    return result.data["chatId"] as String;
  }

  final OfferService _offerService = OfferService();
  /// Mesaj Gönder
  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    final senderDoc = await _firestore
        .collection("users")
        .doc(message.senderId)
        .get();

    final receiverDoc = await _firestore
        .collection("users")
        .doc(message.receiverId)
        .get();

    final senderBlocked =
    List<String>.from(senderDoc.data()?["blockedUsers"] ?? []);

    final receiverBlocked =
    List<String>.from(receiverDoc.data()?["blockedUsers"] ?? []);

    if (senderBlocked.contains(message.receiverId) ||
        receiverBlocked.contains(message.senderId)) {
      throw Exception("blocked");
    }
    final chatDoc =
    await _firestore.collection("chats").doc(chatId).get();

    final jobId = chatDoc.data()?["jobId"];

    if (jobId != null) {
      final offer = await _offerService.getOfferByJobId(jobId);

if (offer == null) {
throw Exception("Teklif bulunamadı.");
}

      const allowedStatuses = [
        "accepted",
        "in_progress",
        "completed",
        "reviewed",
        "cancelled",
      ];
      print("STATUS = ${offer.status}");
if (!allowedStatuses.contains(offer.status)) {
throw Exception("Bu iş için mesajlaşma artık kapalı.");
}
    }
    await _functions
        .httpsCallable("sendMessage")
        .call({
      "chatId": chatId,
      "senderId": message.senderId,
      "receiverId": message.receiverId,
      "message": message.message,
    });
    }
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _firestore.collection('chats').doc(chatId).set({
      'typing': {
        userId: isTyping,
      },
    }, SetOptions(merge: true));
  }
  Future<void> markMessagesAsDelivered({
    required String chatId,
    required String currentUserId,
  }) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.update({
        'status': 'delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
      });
    }
  }
  Future<void> markMessagesAsSeen({
    required String chatId,
    required String currentUserId,
  }) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'delivered')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.update({
        'status': 'seen',
        'seenAt': FieldValue.serverTimestamp(),
      });
    }
    await _firestore
        .collection("chats")
        .doc(chatId)
        .set({
      "unreadCount": {
        currentUserId: 0,
      },
    }, SetOptions(merge: true));
  }
  Stream<List<MessageModel>> getMessages({
    required String chatId,
    required String userId,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .asyncMap((chatSnapshot) async {
      DateTime? clearDate;

      if (chatSnapshot.exists) {
        final data = chatSnapshot.data();

        if (data != null &&
            data["clearedBy"] != null &&
            data["clearedBy"][userId] != null) {
          clearDate =
              (data["clearedBy"][userId] as Timestamp).toDate();
        }
      }

      final messageSnapshot = await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .orderBy("createdAt")
          .get();

      final messages = messageSnapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .where((message) {
        if (clearDate == null) return true;

        return message.createdAt.isAfter(clearDate);
      })
          .toList();

      return messages;
    });
  }

  Future<String> uploadChatImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = _storage
        .ref()
        .child("chat_images")
        .child(fileName);

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> deleteChat({
    required String chatId,
  }) async {
    final messages = await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    await _firestore
        .collection("chats")
        .doc(chatId)
        .delete();
  }
  Future<void> deleteChatByJobId(String jobId) async {
    print("DELETE CHAT BAŞLADI: $jobId");

    final chatRef = _firestore.collection("chats").doc(jobId);

    final chatDoc = await chatRef.get();

    print("CHAT VAR MI: ${chatDoc.exists}");

    final messages = await chatRef.collection("messages").get();

    print("MESAJ SAYISI: ${messages.docs.length}");

    for (final message in messages.docs) {
      print("MESAJ SİLİNİYOR: ${message.id}");
      await message.reference.delete();
    }

    print("CHAT SİLİNİYOR");

    await chatRef.delete();

    print("CHAT SİLİNDİ");
  }
}