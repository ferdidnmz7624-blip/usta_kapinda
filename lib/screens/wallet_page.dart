import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_transaction_model.dart';
import '../services/wallet_service.dart';
import 'package:intl/intl.dart';
import '../generated/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletService _walletService = WalletService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(title: Text(l10n.tokens), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.tokenTransactions,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<List<WalletTransactionModel>>(
              stream: _walletService.getTransactions(uid),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        "Hesap hareketleri şu an yüklenemedi. Lütfen tekrar deneyin.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data!;

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(l10n.noTransactionsYet),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];

                    final income = item.tokens >= 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.type == "token_purchase"
                              ? Colors.green
                              : item.type == "offer"
                              ? Colors.orange
                              : item.type == "bonus"
                              ? Colors.red
                              : Colors.blue,
                          child: Icon(
                            item.type == "token_purchase"
                                ? Icons.monetization_on
                                : item.type == "offer"
                                ? Icons.local_offer
                                : item.type == "bonus"
                                ? Icons.card_giftcard
                                : Icons.receipt_long,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(
                          item.type == "token_purchase"
                              ? l10n.tokensPurchased
                              : item.type == "offer"
                              ? l10n.offerSent
                              : item.type == "bonus"
                              ? l10n.bonusTokens
                              : l10n.transaction,
                        ),
                        subtitle: Text(
                          DateFormat(
                            "dd MMMM yyyy - HH:mm",
                            "tr_TR",
                          ).format(item.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        trailing: Text(
                          "${income ? "+" : ""}${item.tokens} 🪙",
                          style: TextStyle(
                            color: income ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
