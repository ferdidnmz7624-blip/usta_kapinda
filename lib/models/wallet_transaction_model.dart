import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransactionModel {
  final String id;
  final String uid;
  final String type;
  final int tokens;
  final String description;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.tokens,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WalletTransactionModel(
      id: doc.id,
      uid: data["uid"] ?? "",
      type: data["type"] ?? "",
      tokens: data["tokens"] ?? 0,
      description: data["description"] ?? "",
      createdAt: data["createdAt"] != null
          ? (data["createdAt"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "type": type,
      "tokens": tokens,
      "description": description,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}