import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../providers/language_provider.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {"name": "Türkçe", "code": "tr", "flag": "🇹🇷"},
      {"name": "English", "code": "en", "flag": "🇺🇸"},
      {"name": "Deutsch", "code": "de", "flag": "🇩🇪"},
      {"name": "Русский", "code": "ru", "flag": "🇷🇺"},
      {"name": "العربية", "code": "ar", "flag": "🇸🇦"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];

          return ListTile(
            leading: Text(
              language["flag"]!,
              style: const TextStyle(fontSize: 28),
            ),
            title: Text(language["name"]!),
            trailing: provider.locale.languageCode == language["code"]
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () async {
              await provider.changeLanguage(language["code"]!);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}