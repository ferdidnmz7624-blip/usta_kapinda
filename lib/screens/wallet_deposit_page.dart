import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'wallet_page.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';

class WalletDepositPage extends StatefulWidget {
  const WalletDepositPage({super.key});

  @override
  State<WalletDepositPage> createState() => _WalletDepositPageState();
}

class _WalletDepositPageState extends State<WalletDepositPage> {
  final UserService _userService = UserService();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  int tokenBalance = 0;
  bool _storeAvailable = false;
  bool _loadingProducts = true;
  String? _storeMessage;

  final Map<String, ProductDetails> _products = {};

  final List<Map<String, dynamic>> packages = [
    {
      "productId": "tokens_120",
      "tokens": 120,
      "base": 100,
      "bonus": 20,
      "price": "150 ₺",
      "popular": true,
      "color": const Color(0xff27AE60),
    },
    {
      "productId": "tokens_240",
      "tokens": 240,
      "base": 200,
      "bonus": 40,
      "price": "300 ₺",
      "popular": false,
      "color": const Color(0xff2D9CDB),
    },
    {
      "productId": "tokens_480",
      "tokens": 480,
      "base": 400,
      "bonus": 80,
      "price": "600 ₺",
      "popular": false,
      "color": const Color(0xff9B51E0),
    },
    {
      "productId": "tokens_960",
      "tokens": 960,
      "base": 800,
      "bonus": 160,
      "price": "1200 ₺",
      "popular": false,
      "color": const Color(0xffF2994A),
    },
    {
      "productId": "tokens_1920",
      "tokens": 1920,
      "base": 1600,
      "bonus": 320,
      "price": "2400 ₺",
      "popular": false,
      "color": const Color(0xffF2C94C),
    },
  ];

  @override
  void initState() {
    super.initState();

    loadBalance();
    _initializeStore();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadBalance() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userData = await _userService.getUser(user.uid);

    if (userData == null || !mounted) return;

    setState(() {
      tokenBalance = userData.tokens;
    });
  }

  Future<void> _initializeStore() async {
    if (_purchaseSubscription == null) {
      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _purchaseSubscription?.cancel(),
        onError: (error) => debugPrint("Satın alma akışı hatası: $error"),
      );
    }

    if (mounted) {
      setState(() {
        _loadingProducts = true;
        _storeMessage = null;
      });
    }

    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        if (mounted) {
          setState(() {
            _storeAvailable = false;
            _loadingProducts = false;
            _storeMessage =
                "App Store bağlantısı hazır değil. Lütfen tekrar deneyin.";
          });
        }
        return;
      }

      final productIds = packages
          .map<String>((package) => package["productId"] as String)
          .toSet();
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint("Mağaza ürün sorgulama hatası: ${response.error}");
      }

      _products
        ..clear()
        ..addEntries(
          response.productDetails.map(
            (product) => MapEntry(product.id, product),
          ),
        );

      if (!mounted) return;

      final hasProducts = _products.isNotEmpty;
      setState(() {
        _storeAvailable = hasProducts;
        _loadingProducts = false;
        _storeMessage = hasProducts
            ? null
            : "Jeton paketleri henüz App Store'dan alınamadı. "
                "Ürünlerin TestFlight için etkinleşmesi birkaç dakika sürebilir.";
      });
    } catch (error) {
      debugPrint("Mağaza başlatma hatası: $error");
      if (mounted) {
        setState(() {
          _storeAvailable = false;
          _loadingProducts = false;
          _storeMessage =
              "Mağazaya bağlanılamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.";
        });
      }
    }
  }

  Future<void> _buyPackage(
      Map<String, dynamic> item,
      ) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_storeAvailable) {
      _showMessage(
        l10n.storeUnavailable,
      );
      return;
    }

    final productId =
    item["productId"] as String;

    final product = _products[productId];

    if (product == null) {
      _showMessage(
        l10n.productNotFound,
      );
      return;
    }

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );
    } catch (error) {
      debugPrint(
        "Satın alma başlatma hatası: $error",
      );

      if (!mounted) return;

      _showMessage(
        l10n.purchaseStartFailed,
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases,
      ) async {
    final l10n = AppLocalizations.of(context)!;

    for (final purchase in purchases) {
      debugPrint(
        "Purchase status: "
            "${purchase.productID} - "
            "${purchase.status}",
      );

      if (purchase.status ==
          PurchaseStatus.pending) {
        if (mounted) {
          _showMessage(
            l10n.purchasePending,
          );
        }

        continue;
      }

      if (purchase.status ==
          PurchaseStatus.error) {
        debugPrint(
          "Google Play satın alma hatası: "
              "${purchase.error}",
        );

        if (mounted) {
          _showMessage(
            l10n.purchaseFailed,
          );
        }

        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(
            purchase,
          );
        }

        continue;
      }

      if (purchase.status ==
          PurchaseStatus.purchased ||
          purchase.status ==
              PurchaseStatus.restored) {
        await _verifyPurchaseOnServer(
          purchase,
        );
      }
    }
  }

  Future<void> _verifyPurchaseOnServer(
      PurchaseDetails purchase,
      ) async {
    final l10n = AppLocalizations.of(context)!;

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        _showMessage(
          l10n.sessionNotFound,
        );
      }

      return;
    }

    final purchaseToken =
        purchase.verificationData
            .serverVerificationData;

    if (purchaseToken.isEmpty) {
      if (mounted) {
        _showMessage(
          l10n.purchaseVerificationInfoMissing,
        );
      }

      return;
    }

    var verified = false;

    try {
      final isAppStorePurchase =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

      final callable =
      FirebaseFunctions.instanceFor(
        region: "europe-west1",
      ).httpsCallable(
        isAppStorePurchase
            ? "verifyAppStoreTokenPurchase"
            : "verifyGooglePlayTokenPurchase",
      );

      final result = await callable.call({
        "productId": purchase.productID,
        if (isAppStorePurchase) ...{
          "receiptData": purchaseToken,
          "transactionId": purchase.purchaseID,
        } else
          "purchaseToken": purchaseToken,
      });

      final data =
      Map<String, dynamic>.from(
        result.data as Map,
      );

      if (data["success"] == true) {
        verified = true;
        final tokensAdded =
        data["tokensAdded"];

        await loadBalance();

        if (!mounted) return;

        if (data["alreadyProcessed"] == true) {
          _showMessage(
            l10n.purchaseAlreadyProcessed,
          );
        } else {
          _showMessage(
            l10n.tokensAdded(
              tokensAdded.toString(),
            ),
          );
        }
      }
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        "Firebase satın alma doğrulama hatası: "
            "${error.code} - ${error.message}",
      );

      if (!mounted) return;

      _showMessage(
        l10n.purchaseNotVerified,
      );
    } catch (error) {
      debugPrint(
        "Satın alma doğrulama hatası: $error",
      );

      if (!mounted) return;

      _showMessage(
        l10n.purchaseNotVerified,
      );
    } finally {
      // Ödeme yalnızca sunucu doğrulaması başarılıysa tamamlanır. Böylece
      // bağlantı veya doğrulama hatasında kullanıcı jetonunu kaybetmez.
      if (verified && purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(
          purchase,
        );
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
    AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
      const Color(0xffF4F6FB),

      appBar: AppBar(
        title: Text(
          l10n.tokenStore,
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(16),

        children: [
          Container(
            padding:
            const EdgeInsets.all(22),

            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(24),

              gradient:
              const LinearGradient(
                colors: [
                  Color(0xff081A4A),
                  Color(0xff103B8A),
                ],
              ),
            ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.amber,
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tokenBalance,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$tokenBalance ${l10n.tokens}",
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WalletPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("İşlemler"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(
            height: 24,
          ),

          Container(
            padding:
            const EdgeInsets.all(18),

            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  l10n.whatAreTokensFor,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  l10n.tokensUsedForOffers,
                  style:
                  const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  l10n.tokensPerOffer,
                  style:
                  const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          if (_loadingProducts)
            const Center(
              child:
              CircularProgressIndicator(),
            ),

          if (!_loadingProducts &&
              !_storeAvailable)
            Center(
              child: Column(
                children: [
                  Text(
                    _storeMessage ?? l10n.storeUnavailable,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _initializeStore,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Tekrar dene"),
                  ),
                ],
              ),
            ),

          // App Store ürün sorgusu, sözleşme veya inceleme işlemi sürerken
          // geçici olarak boş dönebilir. iOS'ta paketleri gizlemek yerine
          // görünür bırakırız; satın alma düğmesi zaten _storeAvailable ile
          // güvenli biçimde pasif kalır.
          if (!_loadingProducts &&
              (_storeAvailable || defaultTargetPlatform == TargetPlatform.iOS))
            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              packages.length,

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.72,
              ),

              itemBuilder:
                  (context, index) {
                return _buildPackageCard(
                  packages[index],
                  l10n,
                );
              },
            ),

          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
      Map<String, dynamic> item,
      AppLocalizations l10n,
      ) {
    final productId =
    item["productId"] as String;

    final product =
    _products[productId];

    final displayPrice =
        product?.price ??
            item["price"].toString();

    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),

        border: Border.all(
          color: item["popular"]
              ? Colors.orange
              : Colors.grey.shade300,
          width: 2,
        ),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceEvenly,

        children: [
          if (item["popular"])
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),

              decoration:
              BoxDecoration(
                color: Colors.orange,
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                l10n.mostPopular,
                style:
                const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),

          CircleAvatar(
            radius: 32,
            backgroundColor:
            item["color"] as Color,

            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 34,
            ),
          ),

          Text(
            "${item["tokens"]} ${l10n.tokens}",
            style:
            const TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          Text(
            "${item["base"]} + "
                "${item["bonus"]} "
                "${l10n.bonus}",
            style:
            const TextStyle(
              color: Colors.grey,
            ),
          ),

          Text(
            displayPrice,
            style:
            const TextStyle(
              color: Colors.green,
              fontWeight:
              FontWeight.bold,
              fontSize: 22,
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 8,
            ),

            child: SizedBox(
              width: double.infinity,
              height: 45,

              child:
              ElevatedButton.icon(
                onPressed:
                product == null
                    ? null
                    : () {
                  _buyPackage(
                    item,
                  );
                },

                icon: const Icon(
                  Icons.shopping_cart,
                  size: 18,
                ),

                label: Text(
                  l10n.purchase,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  item["color"]
                  as Color,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
