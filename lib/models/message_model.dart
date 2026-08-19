class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;

  final String message;

  final String type;

  final String fileUrl;

  final String fileName;

  final String location;

  final String status;

  final DateTime createdAt;

  final DateTime? deliveredAt;

  final DateTime? seenAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,

    this.type = "text",
    this.fileUrl = "",
    this.fileName = "",
    this.location = "",
    this.status = "sent",
    this.deliveredAt,
    this.seenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'location': location,
      'status': status,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
      'seenAt': seenAt,
    };
  }

  factory MessageModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',

      type: map['type'] ?? 'text',

      fileUrl: map['fileUrl'] ?? '',

      fileName: map['fileName'] ?? '',

      location: map['location'] ?? '',

      status: map['status'] ?? 'sent',

      createdAt: map['createdAt'].toDate(),

      deliveredAt: map['deliveredAt'] != null
          ? map['deliveredAt'].toDate()
          : null,

      seenAt: map['seenAt'] != null
          ? map['seenAt'].toDate()
          : null,
    );
  }
}