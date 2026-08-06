import 'dart:async';

import 'package:book_brain/service/ads/ad_availability.dart';
import 'package:book_brain/service/ads/ad_event_logger.dart';
import 'package:book_brain/service/ads/ad_frequency_manager.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAdManager({required this.adUnitId});

  final String Function() adUnitId;
  InterstitialAd? _ad;
  bool _isLoadingInterstitial = false;
  Completer<void>? _loadCompleter;

  Future<void> preload() {
    if (!AdAvailability.adsEnabled || _ad != null) {
      return Future.value();
    }
    if (_isLoadingInterstitial) {
      return _loadCompleter?.future ?? Future.value();
    }

    _isLoadingInterstitial = true;
    final completer = Completer<void>();
    _loadCompleter = completer;
    InterstitialAd.load(
      adUnitId: adUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _ad = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (_) {
          _isLoadingInterstitial = false;
          _ad = null;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  Future<bool> showIfEligible({required AdPlacement placement}) async {
    if (!AdAvailability.adsEnabled ||
        !AdFrequencyManager.instance.canShowInterstitial()) {
      return false;
    }
    final ad = _ad;
    if (ad == null) {
      await preload();
      return false;
    }

    _ad = null;
    final result = Completer<bool>();
    final frequency = AdFrequencyManager.instance;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        frequency.markFullscreenAdStarted(placement);
        AdEventLogger.log('shown', placement);
      },
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        frequency.markFullscreenAdFinished(placement);
        if (!result.isCompleted) result.complete(true);
        preload();
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        frequency.markFullscreenAdFinished(placement);
        if (!result.isCompleted) result.complete(false);
        preload();
      },
    );
    try {
      ad.show();
    } catch (_) {
      ad.dispose();
      if (frequency.isFullscreenAdShowing) {
        frequency.markFullscreenAdFinished(placement);
      }
      if (!result.isCompleted) result.complete(false);
      preload();
    }
    return result.future;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
