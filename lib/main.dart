import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_page.dart';
import 'screens/job_post_page.dart';
import 'screens/jobs_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/account_type_page.dart';
import 'screens/mode_router_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'providers/language_provider.dart';
import 'screens/kvkk_page.dart';
import 'screens/terms_page.dart';
import 'screens/privacy_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const UstaKapindaApp(),
    ),
  );

  // Bildirim ve App Check işlemleri uygulamanın açılmasını bekletmez.
  // Bir iOS izin veya APNs sorunu olsa bile kullanıcı giriş ekranını görür.
  unawaited(_initializeOptionalServices());
}

Future<void> _initializeOptionalServices() async {
  try {
    await initializeDateFormatting('tr_TR');
  } catch (error, stackTrace) {
    debugPrint('Tarih biçimi başlatılamadı: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // StoreKit 1, Apple'ın sunucuda doğrulanabilen makbuz verisini sağlar.
  // Satın alma eklentisi açılmadan önce çalışır, ancak uygulamanın açılışını
  // hiçbir koşulda bekletmez.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      await InAppPurchaseStoreKitPlatform.enableStoreKit1();
    } catch (error, stackTrace) {
      debugPrint('StoreKit başlatılamadı: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  } catch (error, stackTrace) {
    debugPrint('App Check başlatılamadı: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'messages',
      'Mesaj Bildirimleri',
      description: 'Yeni mesaj bildirimleri',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null &&
          defaultTargetPlatform == TargetPlatform.android) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'messages',
              'Mesaj Bildirimleri',
              channelDescription: 'Yeni mesaj bildirimleri',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
    final token = await FirebaseMessaging.instance.getToken();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await UserService().saveFcmToken(user.uid, token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('Yeni FCM tokenı alındı.');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().saveFcmToken(user.uid, newToken);
      }
    });
  } catch (error, stackTrace) {
    debugPrint('Bildirim servisi başlatılamadı: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class UstaKapindaApp extends StatelessWidget {
  const UstaKapindaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Usta Kapında",

          locale: languageProvider.locale,

          localizationsDelegates: AppLocalizations.localizationsDelegates,

          supportedLocales: AppLocalizations.supportedLocales,

          themeMode: languageProvider.themeMode,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,

            scaffoldBackgroundColor: const Color(0xfff4f7fb),

            cardColor: Colors.white,

            dividerColor: Colors.grey.shade300,

            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,

            scaffoldBackgroundColor: const Color(0xff121212),

            cardColor: const Color(0xff1E1E1E),

            dividerColor: Colors.white24,

            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xff1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          routes: {
            "/login": (context) => const LoginPage(),
            // Artık önce hesap türü seçilecek
            "/kvkk": (context) => const KvkkPage(),
            "/terms": (context) => const TermsPage(),
            "/privacy": (context) => const PrivacyPage(),
            "/register": (context) => const AccountTypePage(),

            "/home": (context) => const ModeRouterPage(),
            "/jobs": (context) => const JobsPage(),
            "/job-post": (context) => const JobPostPage(),
          },
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                return const ModeRouterPage();
              }

              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
