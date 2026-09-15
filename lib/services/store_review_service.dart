import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class StoreReviewService {
  StoreReviewService._();

  static const _androidPackageId = 'com.ustakapinda.app';
  static const _iosAppId = '6802899859';

  /// Kullanıcıyı uygulamanın mağazadaki değerlendirme ekranına gönderir.
  /// Android'de Play Store uygulaması yoksa web mağaza sayfasına düşer.
  static Future<bool> openReviewPage() async {
    if (Platform.isIOS) {
      return launchUrl(
        Uri.parse('https://apps.apple.com/app/id$_iosAppId?action=write-review'),
        mode: LaunchMode.externalApplication,
      );
    }

    if (Platform.isAndroid) {
      final marketUri = Uri.parse(
        'market://details?id=$_androidPackageId&reviewId=0',
      );
      if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
        return true;
      }

      return launchUrl(
        Uri.parse(
          'https://play.google.com/store/apps/details?id=$_androidPackageId&reviewId=0',
        ),
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }
}
