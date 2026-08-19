import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_transaction_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<WalletTransactionModel>> getTransactions(String uid) {
    return _firestore
        .collection("wallet_transactions")
        .where("uid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => WalletTransactionModel.fromFirestore(doc))
        .toList());
  }
}