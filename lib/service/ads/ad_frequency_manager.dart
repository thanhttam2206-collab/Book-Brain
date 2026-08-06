import 'package:book_brain/service/ads/ad_defaults.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/utils/core/helpers/local_storage_helper.dart';

class AdFrequencyManager {
  AdFrequencyManager._();

  static final AdFrequencyManager instance = AdFrequencyManager._();
  static const _sessionCountKey = 'ad_session_count';

  DateTime? lastFullscreenAdShownAt;
  DateTime? lastInterstitialShownAt;
  DateTime? lastAppOpenShownAt;
  DateTime? backgroundStartedAt;
  Duration? _lastBackgroundDuration;

  int contentActionCount = 0;
  int sessionCount = 0;
  bool isFullscreenAdShowing = false;
  bool _sessionRegistered = false;

  void registerSession() {
    if (_sessionRegistered) return;
    final stored = LocalStorageHelper.getValue(_sessionCountKey);
    sessionCount = (stored is int ? stored : 0) + 1;
    LocalStorageHelper.setValue(_sessionCountKey, sessionCount);
    _sessionRegistered = true;
  }

  void registerContentAction() => contentActionCount++;

  bool canShowInterstitial() {
    final now = DateTime.now();
    return !isFullscreenAdShowing &&
        contentActionCount >= AdDefaults.interstitialActionThreshold &&
        _elapsed(now, lastInterstitialShownAt) >=
            AdDefaults.interstitialCooldown &&
        _elapsed(now, lastFullscreenAdShownAt) >=
            AdDefaults.fullscreenGlobalCooldown;
  }

  bool canShowAppOpen() {
    final now = DateTime.now();
    return !isFullscreenAdShowing &&
        sessionCount >= AdDefaults.appOpenMinimumSessionCount &&
        (_lastBackgroundDuration ?? Duration.zero) >=
            AdDefaults.appOpenMinimumBackgroundDuration &&
        _elapsed(now, lastAppOpenShownAt) >= AdDefaults.appOpenCooldown &&
        _elapsed(now, lastFullscreenAdShownAt) >=
            AdDefaults.fullscreenGlobalCooldown;
  }

  bool canShowRewarded() {
    if (isFullscreenAdShowing) return false;
    if (lastFullscreenAdShownAt == null) return true;
    return DateTime.now().difference(lastFullscreenAdShownAt!) >=
        const Duration(seconds: 10);
  }

  void markFullscreenAdStarted(AdPlacement placement) {
    isFullscreenAdShowing = true;
    if (placement == AdPlacement.contentNavigationInterstitial) {
      resetContentActionCount();
    }
  }

  void markFullscreenAdFinished(AdPlacement placement) {
    final now = DateTime.now();
    isFullscreenAdShowing = false;
    lastFullscreenAdShownAt = now;
    if (placement == AdPlacement.contentNavigationInterstitial) {
      lastInterstitialShownAt = now;
    } else if (placement == AdPlacement.appResume) {
      lastAppOpenShownAt = now;
    }
  }

  void resetContentActionCount() => contentActionCount = 0;

  void onAppBackgrounded() {
    backgroundStartedAt = DateTime.now();
    _lastBackgroundDuration = null;
  }

  void onAppForegrounded() {
    final startedAt = backgroundStartedAt;
    _lastBackgroundDuration =
        startedAt == null
            ? Duration.zero
            : DateTime.now().difference(startedAt);
    backgroundStartedAt = null;
  }

  Duration _elapsed(DateTime now, DateTime? value) =>
      value == null ? const Duration(days: 36500) : now.difference(value);
}
