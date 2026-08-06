import 'dart:async';

import 'package:book_brain/service/ads/ad_availability.dart';
import 'package:book_brain/service/ads/ad_event_logger.dart';
import 'package:book_brain/service/ads/ad_frequency_manager.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardedAdResult { rewarded, closedEarly, unavailable, failedToShow }

class RewardedAdManager {
  RewardedAdManager({
    required this.rewardedAdUnitId,
    required this.rewardedInterstitialAdUnitId,
  });

  final String Function() rewardedAdUnitId;
  final String Function() rewardedInterstitialAdUnitId;
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoadingRewarded = false;
  bool _isLoadingRewardedInterstitial = false;
  Completer<void>? _rewardedLoadCompleter;
  Completer<void>? _rewardedInterstitialLoadCompleter;

  Future<void> preloadRewarded() {
    if (!AdAvailability.adsEnabled || _rewardedAd != null) {
      return Future.value();
    }
    if (_isLoadingRewarded) {
      return _rewardedLoadCompleter?.future ?? Future.value();
    }
    _isLoadingRewarded = true;
    final completer = Completer<void>();
    _rewardedLoadCompleter = completer;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingRewarded = false;
          _rewardedAd = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (_) {
          _isLoadingRewarded = false;
          _rewardedAd = null;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  Future<void> preloadRewardedInterstitial() {
    if (!AdAvailability.adsEnabled || _rewardedInterstitialAd != null) {
      return Future.value();
    }
    if (_isLoadingRewardedInterstitial) {
      return _rewardedInterstitialLoadCompleter?.future ?? Future.value();
    }
    _isLoadingRewardedInterstitial = true;
    final completer = Completer<void>();
    _rewardedInterstitialLoadCompleter = completer;
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId(),
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingRewardedInterstitial = false;
          _rewardedInterstitialAd = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (_) {
          _isLoadingRewardedInterstitial = false;
          _rewardedInterstitialAd = null;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }

  Future<RewardedAdResult> showRewarded({required AdPlacement placement}) {
    final ad = _rewardedAd;
    if (!AdAvailability.adsEnabled || ad == null) {
      return Future.value(RewardedAdResult.unavailable);
    }
    _rewardedAd = null;
    return _show(
      ad: ad,
      placement: placement,
      setCallback: (callback) => ad.fullScreenContentCallback = callback,
      show: (onReward) => ad.show(onUserEarnedReward: onReward),
      reload: preloadRewarded,
    );
  }

  Future<RewardedAdResult> showRewardedInterstitial({
    required AdPlacement placement,
  }) {
    final ad = _rewardedInterstitialAd;
    if (!AdAvailability.adsEnabled || ad == null) {
      return Future.value(RewardedAdResult.unavailable);
    }
    _rewardedInterstitialAd = null;
    return _show(
      ad: ad,
      placement: placement,
      setCallback: (callback) => ad.fullScreenContentCallback = callback,
      show: (onReward) => ad.show(onUserEarnedReward: onReward),
      reload: preloadRewardedInterstitial,
    );
  }

  Future<RewardedAdResult> _show<T extends AdWithoutView>({
    required T ad,
    required AdPlacement placement,
    required void Function(FullScreenContentCallback<T>) setCallback,
    required void Function(OnUserEarnedRewardCallback) show,
    required Future<void> Function() reload,
  }) async {
    final frequency = AdFrequencyManager.instance;
    if (!frequency.canShowRewarded()) {
      ad.dispose();
      reload();
      return RewardedAdResult.unavailable;
    }
    final completer = Completer<RewardedAdResult>();
    var earnedReward = false;
    setCallback(
      FullScreenContentCallback<T>(
        onAdShowedFullScreenContent: (_) {
          frequency.markFullscreenAdStarted(placement);
          AdEventLogger.log('shown', placement);
        },
        onAdDismissedFullScreenContent: (shownAd) {
          shownAd.dispose();
          frequency.markFullscreenAdFinished(placement);
          if (!completer.isCompleted) {
            completer.complete(
              earnedReward
                  ? RewardedAdResult.rewarded
                  : RewardedAdResult.closedEarly,
            );
          }
          reload();
        },
        onAdFailedToShowFullScreenContent: (failedAd, _) {
          failedAd.dispose();
          frequency.markFullscreenAdFinished(placement);
          if (!completer.isCompleted) {
            completer.complete(RewardedAdResult.failedToShow);
          }
          reload();
        },
      ),
    );
    try {
      show((_, __) => earnedReward = true);
    } catch (_) {
      ad.dispose();
      if (frequency.isFullscreenAdShowing) {
        frequency.markFullscreenAdFinished(placement);
      }
      if (!completer.isCompleted) {
        completer.complete(RewardedAdResult.failedToShow);
      }
      reload();
    }
    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _rewardedAd = null;
    _rewardedInterstitialAd = null;
  }
}
