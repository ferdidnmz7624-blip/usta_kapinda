import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFavorite(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection("favorites")
        .doc(userId)
        .set({
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
  Future<void> toggleFavorite(String userId) async {
    if (await isFavorite(userId)) {
      await removeFavorite(userId);
    } else {
      await addFavorite(userId);
    }
  }
  Future<void> removeFavorite(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection("favorites")
        .doc(userId)
        .delete();
  }

  Stream<QuerySnapshot> getFavorites() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection("users")
        .doc(currentUser!.uid)
        .collection("favorites")
        .snapshots();
  }

  Future<bool> isFavorite(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return false;

    final doc = await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection("favorites")
        .doc(userId)
        .get();

    return doc.exists;
  }
  Stream<List<String>> getFavoriteIds() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection("users")
        .doc(currentUser!.uid)
        .collection("favorites")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((e) => e.id).toList(),
    );
  }
}