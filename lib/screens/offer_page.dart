import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/job_model.dart';
import '../services/offer_service.dart';
import '../generated/app_localizations.dart';

class OfferPage extends StatefulWidget {
  final JobModel job;

  const OfferPage({super.key, required this.job});

  @override
  State<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final OfferService _offerService = OfferService();

  final priceController = TextEditingController();
  final messageController = TextEditingController();
  final daysController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    priceController.dispose();
    messageController.dispose();
    daysController.dispose();
    super.dispose();
  }

  Future<void> sendOffer() async {
    final l10n = AppLocalizations.of(context)!;

    if (priceController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty ||
        daysController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requiredFields)));
      return;
    }

    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final days = int.tryParse(daysController.text.trim()) ?? 0;

    final message = messageController.text.trim();

    if (price < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teklif tutarı en az 1.000 ₺ olmalıdır.')),
      );
      return;
    }

    if (days < 1 || days > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.estimatedDurationRange)));
      return;
    }

    if (message.length < 20) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offerMessageMin)));
      return;
    }

    if (message.length > 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offerMessageMax)));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(l10n.loginRequired);
      }

      final alreadyOffered = await _offerService.hasAlreadyOffered(
        jobId: widget.job.id,
        craftsmanId: user.uid,
      );

      if (alreadyOffered) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.alreadyOffered)));

        return;
      }

      await FirebaseFunctions.instanceFor(
        region: "europe-west1",
      ).httpsCallable("payOfferWithTokens").call({
        "jobId": widget.job.id,
        "price": price,
        "message": message,
        "estimatedDays": days,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offerSent)));

      Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      String errorMessage = l10n.offerCouldNotBeSent;

      if (e.code == "already-exists") {
        errorMessage = l10n.alreadyOffered;
      } else if (e.code == "failed-precondition") {
        errorMessage = l10n.insufficientTokens;
      } else if (e.code == "unauthenticated") {
        errorMessage = l10n.unauthenticated;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.somethingWentWrong)),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = l10n.offerCouldNotBeSent;

      final error = e.toString();

      if (error.contains("already")) {
        errorMessage = l10n.alreadyOffered;
      } else if (error.contains("failed-precondition")) {
        errorMessage = l10n.insufficientTokens;
      } else if (error.contains("unauthenticated")) {
        errorMessage = l10n.unauthenticated;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.makeOffer), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(widget.job.description),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(widget.job.category)),
                        Chip(label: Text(widget.job.city)),
                        Chip(label: Text(widget.job.district)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Teklif tutarı (₺)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.estimatedDuration,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: messageController,
              maxLines: 5,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l10n.offerMessage,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.message),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : sendOffer,
                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isLoading ? l10n.sending : l10n.makeOffer,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.offerInformation)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
