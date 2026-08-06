import 'dart:async';

import 'package:book_brain/service/ads/ad_availability.dart';
import 'package:book_brain/service/ads/ad_event_logger.dart';
import 'package:book_brain/service/ads/ad_frequency_manager.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAdManager({required this.adUnitId});

  final String Function() adUnitId;
  AppOpenAd? _ad;
  bool _isLoadingAppOpen = false;
  Completer<void>? _loadCompleter;

  Future<void> preload() {
    if (!AdAvailability.adsEnabled || _ad != null) return Future.value();
    if (_isLoadingAppOpen) {
      return _loadCompleter?.future ?? Future.value();
    }
    _isLoadingAppOpen = true;
    final completer = Completer<void>();
    _loadCompleter = completer;
    AppOpenAd.load(
      adUnitId: adUnitId(),
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingAppOpen = false;
          _ad = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (_) {
          _isLoadingAppOpen = false;
          _ad = null;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  Future<bool> showIfEligible() async {
    final placement = AdPlacement.appResume;
    final ad = _ad;
    if (!AdAvailability.adsEnabled ||
        ad == null ||
        !AdFrequencyManager.instance.canShowAppOpen()) {
      if (ad == null) preload();
      return false;
    }
    _ad = null;
    final completer = Completer<bool>();
    final frequency = AdFrequencyManager.instance;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        frequency.markFullscreenAdStarted(placement);
        AdEventLogger.log('shown', placement);
      },
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        frequency.markFullscreenAdFinished(placement);
        if (!completer.isCompleted) completer.complete(true);
        preload();
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        frequency.markFullscreenAdFinished(placement);
        if (!completer.isCompleted) completer.complete(false);
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
      if (!completer.isCompleted) completer.complete(false);
      preload();
    }
    return completer.future;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
