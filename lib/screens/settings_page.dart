import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'account_info_page.dart';
import 'language_page.dart';
import 'about_page.dart';
import 'kvkk_page.dart';
import 'terms_page.dart';
import 'privacy_page.dart';
import '../pages/blocked_users_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/google_auth_service.dart';
import 'login_page.dart';
import '../generated/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool messageNotification = true;
  bool offerNotification = true;
  bool jobNotification = true;
  bool campaignNotification = true;

  bool darkMode = false;
  String appVersion = "";

  final SettingsService _settingsService = SettingsService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadVersion();
  }

  Future<void> saveSettings() async {
    await _settingsService.saveSettings(
      SettingsModel(
        messageNotification: messageNotification,
        offerNotification: offerNotification,
        jobNotification: jobNotification,
        campaignNotification: campaignNotification,
        darkMode: darkMode,
      ),
    );
  }

  Future<void> freezeAccount() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.freezeAccount),
        content: Text(
          l10n.freezeAccountConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.freezeAccount),
          ),
        ],
      ),
    );

    if (result != true) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _userService.freezeAccount();

    await GoogleAuthService().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  Future<void> deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(
          l10n.deleteAccountConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteMyAccount),
          ),
        ],
      ),
    );

    if (result != true) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _userService.requestDeleteAccount();

    await GoogleAuthService().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  Future<void> loadSettings() async {
    final settings = await _settingsService.getSettings();

    if (!mounted) return;

    setState(() {
      messageNotification = settings.messageNotification;
      offerNotification = settings.offerNotification;
      jobNotification = settings.jobNotification;
      campaignNotification = settings.campaignNotification;
      darkMode = settings.darkMode;
    });
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      appVersion = "${info.version}+${info.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.account,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  title: Text(l10n.accountInformation),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountInfoPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(l10n.changeEmail),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangeEmailPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.lock,
                    color: Colors.deepPurple,
                  ),
                  title: Text(l10n.changePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.block,
                    color: Colors.red,
                  ),
                  title: Text(l10n.blockedUsers),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlockedUsersPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            l10n.notifications,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.message),
                  title: Text(l10n.messageNotifications),
                  value: messageNotification,
                  onChanged: (v) async {
                    setState(() {
                      messageNotification = v;
                    });

                    await saveSettings();
                  },
                ),

                const Divider(height: 1),

                SwitchListTile(
                  secondary: const Icon(Icons.work),
                  title: Text(l10n.offerNotifications),
                  value: offerNotification,
                  onChanged: (v) async {
                    setState(() {
                      offerNotification = v;
                    });

                    await saveSettings();
                  },
                ),

                const Divider(height: 1),

                SwitchListTile(
                  secondary: const Icon(Icons.campaign),
                  title: Text(l10n.jobNotifications),
                  value: jobNotification,
                  onChanged: (v) async {
                    setState(() {
                      jobNotification = v;
                    });

                    await saveSettings();
                  },
                ),

                const Divider(height: 1),

                SwitchListTile(
                  secondary: const Icon(Icons.local_offer),
                  title: Text(l10n.campaignNotifications),
                  value: campaignNotification,
                  onChanged: (v) async {
                    setState(() {
                      campaignNotification = v;
                    });

                    await saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            l10n.appearance,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(l10n.darkMode),
                  value: darkMode,
                  onChanged: (v) async {
                    setState(() {
                      darkMode = v;
                    });

                    await saveSettings();

                    if (!mounted) return;

                    await Provider.of<LanguageProvider>(
                      context,
                      listen: false,
                    ).changeTheme(v);
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: Colors.green,
                  ),
                  title: Text(l10n.languageSelection),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguagePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            l10n.privacy,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: Colors.purple,
                  ),
                  title: Text(l10n.privacy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KvkkPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.orange,
                  ),
                  title: Text(l10n.termsOfUse),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.security,
                    color: Colors.teal,
                  ),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            l10n.about,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.blueAccent,
                  ),
                  title: Text(l10n.aboutUs),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  title: Text(l10n.rateUs),
                  trailing: const Icon(Icons.chevron_right),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.phone_android,
                    color: Colors.indigo,
                  ),
                  title: Text(
                    appVersion.isEmpty
                        ? l10n.version
                        : "${l10n.version} $appVersion",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            l10n.accountActions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.pause_circle,
                    color: Colors.orange,
                  ),
                  title: Text(l10n.freezeAccount),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: freezeAccount,
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  title: Text(
                    l10n.deleteAccount,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: deleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
