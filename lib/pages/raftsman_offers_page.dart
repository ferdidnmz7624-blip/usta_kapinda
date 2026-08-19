
import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';

class CraftsmanOffersPage extends StatefulWidget {
const CraftsmanOffersPage({super.key});

@override
State<CraftsmanOffersPage> createState() =>
_CraftsmanOffersPageState();
}

class _CraftsmanOffersPageState
extends State<CraftsmanOffersPage>
with SingleTickerProviderStateMixin {
late TabController _tabController;

@override
void initState() {
super.initState();

_tabController = TabController(
length: 5,
vsync: this,
);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context)!;

return Scaffold(
appBar: AppBar(
title: Text(l10n.craftsmanOffers),
bottom: TabBar(
controller: _tabController,
isScrollable: true,
tabs: [
Tab(text: l10n.pending),
Tab(text: l10n.accepted),
Tab(text: l10n.rejected),
Tab(text: l10n.inProgress),
Tab(text: l10n.completed),
],
),
),
body: TabBarView(
controller: _tabController,
children: [
Center(
child: Text(l10n.pendingOffers),
),
Center(
child: Text(l10n.acceptedOffers),
),
Center(
child: Text(l10n.rejectedOffers),
),
Center(
child: Text(l10n.inProgressOffers),
),
Center(
child: Text(l10n.completedOffers),
),
],
),
);
}
}