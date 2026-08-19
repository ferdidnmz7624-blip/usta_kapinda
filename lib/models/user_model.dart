import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String accountType;

  final bool customerProfile;
  final bool craftsmanProfile;
  final String activeMode;
  final String linkedCustomerUid;
  final String linkedCraftsmanUid;

  final String linkedCustomerEmail;
  final String linkedCraftsmanEmail;

  final String firstName;
  final String lastName;

  final String email;
  final String phone;

  final String city;
  final String district;
  final String neighborhood;
  final String address;

  // Sadece usta için kullanılacak
  final List<String> professions;
  final int experience;
  final String about;

  // Ortak alanlar
  final String profilePhoto;
  final double rating;
  final int completedJobs;

  final int tokens;
  final bool isFrozen;
  final bool isDeleting;
  final DateTime? deleteAt;
  final DateTime? createdAt;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    required this.accountType,

    required this.customerProfile,
    required this.craftsmanProfile,
    required this.activeMode,
    required this.linkedCustomerUid,
    required this.linkedCraftsmanUid,

    required this.linkedCustomerEmail,
    required this.linkedCraftsmanEmail,

    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.address,
    required this.professions,
    required this.experience,
    required this.about,
    required this.profilePhoto,
    required this.rating,
    required this.completedJobs,
    required this.tokens,
    required this.createdAt,
    required this.isFrozen,
    required this.isDeleting,
    required this.deleteAt,
    required this.isOnline,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "accountType": accountType,

      "customerProfile": customerProfile,
      "craftsmanProfile": craftsmanProfile,
      "activeMode": activeMode,
      "linkedCustomerUid": linkedCustomerUid,
      "linkedCraftsmanUid": linkedCraftsmanUid,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "city": city,
      "district": district,
      "neighborhood": neighborhood,
      "address": address,
      "professions": professions,
      "experience": experience,
      "about": about,
      "profilePhoto": profilePhoto,
      "rating": rating,
      "completedJobs": completedJobs,
      "tokens": tokens,
      "isFrozen": isFrozen,
      "isDeleting": isDeleting,
      "deleteAt": deleteAt,
      "createdAt": createdAt,
      "isOnline": isOnline,
      "lastSeen": lastSeen,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      accountType: map["accountType"] ?? "",

      customerProfile: map["customerProfile"] ?? false,
      craftsmanProfile: map["craftsmanProfile"] ?? false,
      activeMode: map["activeMode"] ?? map["accountType"] ?? "customer",
      linkedCustomerUid: map["linkedCustomerUid"] ?? "",
      linkedCraftsmanUid: map["linkedCraftsmanUid"] ?? "",

      linkedCustomerEmail: map["linkedCustomerEmail"] ?? "",
      linkedCraftsmanEmail: map["linkedCraftsmanEmail"] ?? "",

      firstName: map["firstName"] ?? "",
      lastName: map["lastName"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      city: map["city"] ?? "",
      district: map["district"] ?? "",
      neighborhood: map["neighborhood"] ?? "",
      address: map["address"] ?? "",
      professions: List<String>.from(
        map["professions"] ?? [],
      ),
      experience: map["experience"] ?? 0,
      about: map["about"] ?? "",
      profilePhoto: map["profilePhoto"] ?? "",
      rating: (map["rating"] ?? 5).toDouble(),
      completedJobs: map["completedJobs"] ?? 0,
      tokens: map["tokens"] ?? 0,
      isFrozen: map["isFrozen"] ?? false,
      isDeleting: map["isDeleting"] ?? false,

      deleteAt: map["deleteAt"] is Timestamp
          ? (map["deleteAt"] as Timestamp).toDate()
          : null,
      createdAt: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : null,
      isOnline: map["isOnline"] ?? false,

      lastSeen: map["lastSeen"] is Timestamp
          ? (map["lastSeen"] as Timestamp).toDate()
          : null,
    );
  }
}