
import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';

class SwitchAccountPage extends StatefulWidget {
final String email;

const SwitchAccountPage({
super.key,
required this.email,
});

@override
State<SwitchAccountPage> createState() =>
_SwitchAccountPageState();
}

class _SwitchAccountPageState
extends State<SwitchAccountPage> {
final passwordController = TextEditingController();

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;

return Scaffold(
appBar: AppBar(
title: Text(l10n.switchAccount),
),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [
TextFormField(
initialValue: widget.email,
enabled: false,
decoration: InputDecoration(
labelText: l10n.email,
),
),

const SizedBox(height: 20),

TextField(
controller: passwordController,
obscureText: true,
decoration: InputDecoration(
labelText: l10n.password,
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {},
child: Text(l10n.login),
),
),
],
),
),
);
}
}