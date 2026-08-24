import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              '${l10n.privacyPolicyText}\n\n${l10n.tiktokMeasurementNotice}',
              style: const TextStyle(fontSize: 16, height: 1.7),
            ),
          ),
        ),
      ),
    );
  }
}
