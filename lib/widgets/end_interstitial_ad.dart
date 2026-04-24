import 'package:google_mobile_ads/google_mobile_ads.dart';

class EndInterstitialAd {
  EndInterstitialAd._();

  static const String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static InterstitialAd? _ad;
  static bool _isLoading = false;

  static void preload() {
    if (_ad != null || _isLoading) {
      return;
    }

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              preload();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              preload();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
        },
      ),
    );
  }

  static void showIfReady() {
    if (_ad != null) {
      final ad = _ad!;
      _ad = null;
      ad.show();
      return;
    }

    preload();
  }
}
