import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: "europe-west1",
  );
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == uid;
    final collection = isCurrentUser ? 'users' : 'public_profiles';
    final doc = await _firestore.collection(collection).doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection("users").doc(user.uid).update({
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
    });
  }

  Future<void> changeAccountType(String accountType) async {
    await _functions.httpsCallable("changeAccountType").call({
      "accountType": accountType,
    });
  }

  Future<void> changeActiveMode(String activeMode) async {
    await _functions.httpsCallable("changeActiveMode").call({
      "activeMode": activeMode,
    });
  }

  Future<void> activateCustomerProfile() async {
    await _functions.httpsCallable("activateCustomerProfile").call();
  }

  Future<void> activateCraftsmanProfile() async {
    await _functions.httpsCallable("activateCraftsmanProfile").call();
  }

  Future<void> updateProfilePhoto(String uid, String photoUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'profilePhoto': photoUrl,
    });
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _firestore.collection("users").doc(uid).set({
      "fcmToken": token,
    }, SetOptions(merge: true));
  }

  /// İki ayrı Firebase hesabını, her iki oturumun kanıtı doğrulanarak
  /// sunucu tarafında bağlar. İstemci başka kullanıcının belgesini yazmaz.
  Future<void> linkAccounts({required String sourceIdToken}) async {
    final targetIdToken = await FirebaseAuth.instance.currentUser?.getIdToken(
      true,
    );
    if (targetIdToken == null || targetIdToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Bağlanacak hedef hesabın oturumu bulunamadı.',
      );
    }

    await _functions.httpsCallable('linkAccounts').call({
      'sourceIdToken': sourceIdToken,
      'targetIdToken': targetIdToken,
    });
  }

  Stream<UserModel?> streamUser(String uid) {
    final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == uid;
    final collection = isCurrentUser ? 'users' : 'public_profiles';
    return _firestore.collection(collection).doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!);
    });
  }

  Future<void> setOnlineStatus(String uid, bool online) async {
    await _firestore.collection("users").doc(uid).update({
      "isOnline": online,
      "lastSeen": Timestamp.now(),
    });
  }

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore.collection("users").doc(currentUserId).set({
      "blockedUsers": FieldValue.arrayUnion([blockedUserId]),
    }, SetOptions(merge: true));
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore.collection("users").doc(currentUserId).set({
      "blockedUsers": FieldValue.arrayRemove([blockedUserId]),
    }, SetOptions(merge: true));
  }

  Future<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final doc = await _firestore.collection("users").doc(currentUserId).get();

    if (!doc.exists) return false;

    final data = doc.data();

    if (data == null) return false;

    final blockedUsers = List<String>.from(data["blockedUsers"] ?? []);

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

          final blockedUsers = List<String>.from(data["blockedUsers"] ?? []);

          if (blockedUsers.isEmpty) {
            return <UserModel>[];
          }

          final List<UserModel> users = [];

          for (final uid in blockedUsers) {
            final userDoc = await _firestore
                .collection("public_profiles")
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
          final myBlocked = List<String>.from(
            myDoc.data()?["blockedUsers"] ?? [],
          );
          // Karşı tarafın engel listesi gizlidir; kesin kontrol sendMessage
          // Cloud Function'ında yapılır.
          return !myBlocked.contains(otherUserId);
        });
  }

  Stream<bool> isBlockedStream({
    required String currentUserId,
    required String blockedUserId,
  }) {
    return _firestore.collection("users").doc(currentUserId).snapshots().map((
      doc,
    ) {
      final blockedUsers = List<String>.from(doc.data()?["blockedUsers"] ?? []);

      return blockedUsers.contains(blockedUserId);
    });
  }

  Stream<List<UserModel>> getCraftsmen() {
    return _firestore
        .collection("public_profiles")
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
    await _functions.httpsCallable("freezeAccount").call();
  }

  Future<void> unfreezeAccount() async {
    await _functions.httpsCallable("unfreezeAccount").call();
  }

  Future<void> requestDeleteAccount() async {
    await _functions.httpsCallable("requestDeleteAccount").call();
  }

  Future<void> cancelDeleteAccount() async {
    await _functions.httpsCallable("cancelDeleteAccount").call();
  }
}
