import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String jobId;
  final String customerId;
  final String craftsmanId;
  final String lastMessage;
  final Timestamp lastMessageTime;

  ChatModel({
    required this.id,
    required this.jobId,
    required this.customerId,
    required this.craftsmanId,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "jobId": jobId,
      "customerId": customerId,
      "craftsmanId": craftsmanId,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map["id"],
      jobId: map["jobId"],
      customerId: map["customerId"],
      craftsmanId: map["craftsmanId"],
      lastMessage: map["lastMessage"],
      lastMessageTime: map["lastMessageTime"],
    );
  }
}