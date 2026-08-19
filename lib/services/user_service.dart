import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';


class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(
    region: "europe-west1",
  );
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    print("ARAMA UID: $uid");

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    print("BELGE VAR MI: ${doc.exists}");

    if (!doc.exists) {
      return null;
    }

    print("VERİ: ${doc.data()}");

    return UserModel.fromMap(doc.data()!);
  }
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection("users")
        .doc(user.uid)
        .update({
      "firstName": user.firstName,
      "lastName": user.lastName,
      "phone": user.phone,
      "city": user.city,
      "district": user.district,
      "neighborhood": user.neighborhood,
      "address": user.address,
      "professions": user.professions,
      "experience": user.experience,
      "about": user.about,
      "profilePhoto": user.profilePhoto,
      "activeMode": user.activeMode,
      "linkedCustomerUid": user.linkedCustomerUid,
      "linkedCraftsmanUid": user.linkedCraftsmanUid,
      "linkedCustomerEmail": user.linkedCustomerEmail,
      "linkedCraftsmanEmail": user.linkedCraftsmanEmail,
    });
  }

  Future<void> changeAccountType(String accountType) async {
    await _functions
        .httpsCallable("changeAccountType")
        .call({
      "accountType": accountType,
    });
  }

  Future<void> changeActiveMode(String activeMode) async {
    await _functions
        .httpsCallable("changeActiveMode")
        .call({
      "activeMode": activeMode,
    });
  }

  Future<void> activateCustomerProfile() async {
    await _functions
        .httpsCallable("activateCustomerProfile")
        .call();
  }

  Future<void> activateCraftsmanProfile() async {
    await _functions
        .httpsCallable("activateCraftsmanProfile")
        .call();
  }
  Future<void> updateProfilePhoto(
      String uid,
      String photoUrl,
      ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'profilePhoto': photoUrl,
    });
  }


  Future<void> saveFcmToken(
      String uid,
      String token,
      ) async {
    print("Firestore'a token yazılıyor...");
    print(uid);
    print(token);

    await _firestore
        .collection("users")
        .doc(uid)
        .set({
      "fcmToken": token,
    }, SetOptions(merge: true));

    print("Firestore yazma tamamlandı.");
  }
  Future<void> updateLinkedAccounts({
    required String uid,
    String? linkedCustomerUid,
    String? linkedCraftsmanUid,
    String? linkedCustomerEmail,
    String? linkedCraftsmanEmail,
  }) async {
    final Map<String, dynamic> data = {};

    if (linkedCustomerUid != null) {
      data["linkedCustomerUid"] = linkedCustomerUid;
    }
    if (linkedCustomerEmail != null) {
      data["linkedCustomerEmail"] = linkedCustomerEmail;
    }

    if (linkedCraftsmanEmail != null) {
      data["linkedCraftsmanEmail"] = linkedCraftsmanEmail;
    }
    if (linkedCraftsmanUid != null) {
      data["linkedCraftsmanUid"] = linkedCraftsmanUid;
    }

    await _firestore
        .collection("users")
        .doc(uid)
        .update(data);
  }
  Future<UserModel?> getUserByEmail(String email) async {
    final query = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return UserModel.fromMap(query.docs.first.data());
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!);
    });
  }
  Future<void> setOnlineStatus(
      String uid,
      bool online,
      ) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .update({
      "isOnline": online,
      "lastSeen": Timestamp.now(),
    });
  }
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .set({
      "blockedUsers": FieldValue.arrayUnion([
        blockedUserId,
      ]),
    }, SetOptions(merge: true));
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .set({
      "blockedUsers": FieldValue.arrayRemove([
        blockedUserId,
      ]),
    }, SetOptions(merge: true));
  }

  Future<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final doc = await _firestore
        .collection("users")
        .doc(currentUserId)
        .get();

    if (!doc.exists) return false;

    final data = doc.data();

    if (data == null) return false;

    final blockedUsers =
    List<String>.from(data["blockedUsers"] ?? []);

    return blockedUsers.contains(otherUserId);
  }
  Stream<List<UserModel>> getBlockedUsers(String currentUserId) {
    return _firestore
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <UserModel>[];

      final data = doc.data()!;

      final blockedUsers =
      List<String>.from(data["blockedUsers"] ?? []);

      if (blockedUsers.isEmpty) {
        return <UserModel>[];
      }

      final List<UserModel> users = [];

      for (final uid in blockedUsers) {
        final userDoc = await _firestore
            .collection("users")
            .doc(uid)
            .get();

        if (userDoc.exists) {
          users.add(UserModel.fromMap(userDoc.data()!));
        }
      }

      return users;
    });
  }
  Stream<bool> canUsersChat({
    required String currentUserId,
    required String otherUserId,
  }) {
    return _firestore
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .asyncMap((myDoc) async {
      final otherDoc = await _firestore
          .collection("users")
          .doc(otherUserId)
          .get();

      final myBlocked =
      List<String>.from(myDoc.data()?["blockedUsers"] ?? []);

      final otherBlocked =
      List<String>.from(otherDoc.data()?["blockedUsers"] ?? []);

      return !(myBlocked.contains(otherUserId) ||
          otherBlocked.contains(currentUserId));
    });
  }
  Stream<bool> isBlockedStream({
    required String currentUserId,
    required String blockedUserId,
  }) {
    return _firestore
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .map((doc) {
      final blockedUsers =
      List<String>.from(doc.data()?["blockedUsers"] ?? []);

      return blockedUsers.contains(blockedUserId);
    });
  }
  Stream<List<UserModel>> getCraftsmen() {
    return _firestore
        .collection("users")
        .where("accountType", isEqualTo: "craftsman")
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((e) => UserModel.fromMap(e.data()))
          .toList();

      users.sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);

        if (ratingCompare != 0) {
          return ratingCompare;
        }

        return b.completedJobs.compareTo(a.completedJobs);
      });
      users.removeWhere((user) => user.isFrozen);
      return users;
    });
  }
  Future<void> freezeAccount() async {
    await _functions
        .httpsCallable("freezeAccount")
        .call();
  }

  Future<void> unfreezeAccount() async {
    await _functions
        .httpsCallable("unfreezeAccount")
        .call();
  }
  Future<void> requestDeleteAccount() async {
    await _functions
        .httpsCallable("requestDeleteAccount")
        .call();
  }

  Future<void> cancelDeleteAccount() async {
    await _functions
        .httpsCallable("cancelDeleteAccount")
        .call();
  }
}