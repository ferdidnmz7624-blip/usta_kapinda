import 'package:flutter/material.dart';
import '../screens/register_page.dart';
import '../generated/app_localizations.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key});

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.accountType,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Text(
                l10n.selectAccountType,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              _accountCard(
                title: l10n.customer,
                subtitle: l10n.lookingForCraftsman,
                value: "customer",
                icon: Icons.person,
              ),

              const SizedBox(height: 20),

              _accountCard(
                title: l10n.craftsman,
                subtitle: l10n.lookingForJob,
                value: "craftsman",
                icon: Icons.engineering,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedType == null
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterPage(
                          accountType: selectedType!,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n.continueButton,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final bool selected = selectedType == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedType = value;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? Colors.blue
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? Colors.blue.withOpacity(0.08)
              : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: selected
                  ? Colors.blue
                  : Colors.grey,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Radio<String>(
              value: value,
              groupValue: selectedType,
              onChanged: (v) {
                setState(() {
                  selectedType = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}