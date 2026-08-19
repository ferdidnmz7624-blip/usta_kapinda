import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class AddJobPage extends StatelessWidget {
  const AddJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.postListing,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}