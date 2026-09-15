import 'package:flutter/foundation.dart';

/// Sosyal sağlayıcıdan kimlik alındıktan sonra rol ve profil denetimi
/// tamamlanana kadar uygulamanın oturum dinleyicisinin ana ekrana erken
/// yönlendirmesini engeller.
class SocialLoginFlow {
  SocialLoginFlow._();

  static final ValueNotifier<bool> isInProgress = ValueNotifier<bool>(false);

  static void begin() => isInProgress.value = true;

  static void finish() => isInProgress.value = false;
}
