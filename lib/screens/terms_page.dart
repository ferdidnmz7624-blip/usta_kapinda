import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsOfUse),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              '''
KULLANIM KOŞULLARI

Son Güncelleme: 03 Ağustos 2026

Lütfen Usta Kapında uygulamasını kullanmadan önce aşağıdaki kullanım koşullarını dikkatlice okuyunuz. Uygulamayı kullanmanız aşağıdaki şartları kabul ettiğiniz anlamına gelir.

1. UYGULAMANIN AMACI

Usta Kapında, hizmet almak isteyen müşteriler ile hizmet sunan ustaları bir araya getiren dijital bir platformdur. Platform yalnızca tarafların iletişim kurmasını sağlar.

2. ÜYELİK

• Üyelik sırasında doğru ve güncel bilgiler verilmelidir.
• Yanıltıcı veya sahte bilgilerle hesap oluşturulamaz.
• Her kullanıcı kendi hesabının güvenliğinden sorumludur.

3. KULLANICI SORUMLULUKLARI

Kullanıcı;

• Yasalara uygun davranacağını,
• Başka kişilerin haklarını ihlal etmeyeceğini,
• Sahte ilan oluşturmayacağını,
• Yanıltıcı bilgi paylaşmayacağını,
• Başkalarına ait hesapları kullanmayacağını kabul eder.

4. USTA SORUMLULUKLARI

Ustalar;

• Doğru hizmet bilgisi vermek,
• Verdikleri tekliflerden sorumlu olmak,
• Müşterilere saygılı davranmak,
• Yasalara uygun hizmet sunmak

ile yükümlüdür.

5. MÜŞTERİ SORUMLULUKLARI

Müşteriler;

• Gerçeğe uygun iş ilanı oluşturmak,
• Yanıltıcı ilan vermemek,
• Ustalara karşı saygılı davranmak,
• Hizmet sürecinde dürüst hareket etmek

ile yükümlüdür.

6. YASAKLANAN DAVRANIŞLAR

Aşağıdaki davranışlar kesinlikle yasaktır:

• Hakaret ve tehdit
• Dolandırıcılık
• Sahte hesap oluşturmak
• Başkasına ait bilgileri kullanmak
• Spam göndermek
• Sistemi kötüye kullanmak
• Yasadışı faaliyetlerde bulunmak

7. İLAN VE TEKLİFLER

Platform üzerinde oluşturulan ilanlar ve teklifler tamamen kullanıcıların sorumluluğundadır. Usta Kapında, kullanıcılar arasında yapılan anlaşmaların tarafı değildir.

8. HESAPLAR

Kuralları ihlal eden kullanıcıların hesapları;

• Geçici olarak askıya alınabilir,
• Dondurulabilir,
• Kalıcı olarak silinebilir.

9. FİKRİ MÜLKİYET

Uygulamanın tasarımı, yazılımı, logosu ve içerikleri Usta Kapında'ya aittir. İzinsiz kopyalanamaz, çoğaltılamaz veya ticari amaçla kullanılamaz.

10. SORUMLULUĞUN SINIRLANDIRILMASI

Usta Kapında;

• Kullanıcılar arasında yapılan anlaşmalardan,
• Hizmet kalitesinden,
• Ödeme anlaşmazlıklarından,
• Oluşabilecek maddi veya manevi zararlardan

doğrudan sorumlu değildir.

11. GÜNCELLEMELER

Bu kullanım koşulları gerekli görüldüğünde güncellenebilir. Güncel sürüm uygulama içerisinde yayınlanır.

12. İLETİŞİM

Sorularınız için bizimle iletişime geçebilirsiniz.

E-posta:
support@ustakapida.org

Usta Kapında uygulamasını kullanmaya devam ederek bu Kullanım Koşullarını okuduğunuzu, anladığınızı ve kabul ettiğinizi beyan etmiş olursunuz.
''',
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