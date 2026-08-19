import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/offer_model.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = "offers";



  Future<void> updateOffer(OfferModel offer) async {
    await _firestore
        .collection(_collection)
        .doc(offer.id)
        .update(offer.toMap());
  }

  Future<void> deleteOffer(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .delete();
  }

  Future<OfferModel?> getOffer(String id) async {
    final doc =
    await _firestore.collection(_collection).doc(id).get();

    if (!doc.exists) return null;

    return OfferModel.fromMap(doc.data()!);
  }

  Stream<List<OfferModel>> getOffersByJob(String jobId) {
    return _firestore
        .collection(_collection)
        .where("jobId", isEqualTo: jobId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<OfferModel>> getOffersByCraftsman(
      String craftsmanId) {
    return _firestore
        .collection(_collection)
        .where("craftsmanId", isEqualTo: craftsmanId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data()))
          .toList();
    });
  }
  Stream<List<OfferModel>> getAcceptedOffersByCraftsman(
      String craftsmanId) {
    return _firestore
        .collection(_collection)
        .where("craftsmanId", isEqualTo: craftsmanId)
        .where("status", isEqualTo: "accepted")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data()))
          .toList();
    });
  }
  Stream<List<OfferModel>> getOffersByCustomer(
      String customerId) {
    return _firestore
        .collection(_collection)
        .where("customerId", isEqualTo: customerId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data()))
          .toList();
    });
  }

  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(
    region: "europe-west1",
  );

  Future<void> acceptOffer(String offerId) async {
    await _functions
        .httpsCallable("acceptOffer")
        .call({
      "offerId": offerId,
    });
  }

  Future<void> rejectOffer(String offerId) async {
    await _functions
        .httpsCallable("rejectOffer")
        .call({
      "offerId": offerId,
    });
  }
  Future<bool> hasAlreadyOffered({
    required String jobId,
    required String craftsmanId,
  }) async {
    final result = await _firestore
        .collection(_collection)
        .where("jobId", isEqualTo: jobId)
        .where("craftsmanId", isEqualTo: craftsmanId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }
  Stream<List<OfferModel>> getOffersByCraftsmanAndStatus({
    required String craftsmanId,
    required String status,
  }) {
    return _firestore
        .collection(_collection)
        .where("craftsmanId", isEqualTo: craftsmanId)
        .where("status", isEqualTo: status)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data()))
          .toList();
    });
  }
  Future<void> updateOfferStatus({
    required String offerId,
    required String status,
  }) async {
    await _functions
        .httpsCallable("updateOfferStatus")
        .call({
      "offerId": offerId,
      "status": status,
    });
  }
  Future<OfferModel?> getOfferByJobId(String jobId) async {
    final result = await _firestore
        .collection(_collection)
        .where("jobId", isEqualTo: jobId)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    return OfferModel.fromMap(result.docs.first.data());
  }
  Future<void> markCustomerReviewed(String offerId) async {
    final ref = FirebaseFirestore.instance
        .collection("offers")
        .doc(offerId);

    await ref.update({
      "customerReviewed": true,
    });

    final doc = await ref.get();

    final data = doc.data();

    if (data == null) return;

    if (data["craftsmanReviewed"] == true) {
      await ref.update({
        "status": "reviewed",
      });
    }
  }

  Future<void> markCraftsmanReviewed(String offerId) async {
    final ref = FirebaseFirestore.instance
        .collection("offers")
        .doc(offerId);

    await ref.update({
      "craftsmanReviewed": true,
    });

    final doc = await ref.get();

    final data = doc.data();

    if (data == null) return;

    if (data["customerReviewed"] == true) {
      await ref.update({
        "status": "reviewed",
      });
    }
  }
  Future<void> markAllOffersAsSeen(String customerId) async {
    final offers = await _firestore
        .collection(_collection)
        .where("customerId", isEqualTo: customerId)
        .where("isSeenByCustomer", isEqualTo: false)
        .get();

    for (final doc in offers.docs) {
      await doc.reference.update({
        "isSeenByCustomer": true,
      });
    }
  }
}