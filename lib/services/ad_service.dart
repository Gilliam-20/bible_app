import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralizes ad configuration and keeps adverts out of the reading flow.
///
/// The IDs below are Google's official test IDs. Replace them with your own
/// AdMob unit IDs before publishing a production build.
class AdService {
  AdService._();

  static const _androidBannerId = 'ca-app-pub-3940256099942544/9214589741';
  static const _iosBannerId = 'ca-app-pub-3940256099942544/2435281174';
  static const _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static String get bannerId => defaultTargetPlatform == TargetPlatform.iOS
      ? _iosBannerId
      : _androidBannerId;
  static String get interstitialId =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? _iosInterstitialId
      : _androidInterstitialId;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static InterstitialAd? _interstitial;
  static bool _loadingInterstitial = false;
  static int _chapterOpenCount = 0;

  static Future<void> initialize() async {
    if (!isSupported) return;
    await MobileAds.instance.initialize();
    await _requestConsent();
    loadInterstitial();
  }

  static Future<void> _requestConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        }
        if (!completer.isCompleted) completer.complete();
      },
      (_) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
  }

  static void showPrivacyOptions() {
    if (!isSupported) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  static void loadInterstitial() {
    if (!isSupported || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) => _loadingInterstitial = false,
      ),
    );
  }

  /// A full-screen ad is shown at most once every six chapter openings, and
  /// only before navigation to a chapter -- never while someone is reading.
  static void maybeShowChapterInterstitial() {
    if (!isSupported || ++_chapterOpenCount % 6 != 0) return;
    final ad = _interstitial;
    if (ad == null) {
      loadInterstitial();
      return;
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadInterstitial();
      },
    );
    ad.show();
  }
}
