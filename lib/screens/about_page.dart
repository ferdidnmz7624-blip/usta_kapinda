import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutUs,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              AppLocalizations.of(context)!.aboutText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
              ),
            ),
          ),
        ),
      ),
    );
  }
}