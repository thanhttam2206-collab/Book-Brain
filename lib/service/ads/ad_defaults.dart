abstract final class AdDefaults {
  // Aggressive-safe floor: never show more than one interstitial for every
  // two intentional content-navigation actions.
  static const int interstitialActionThreshold = 2;
  static const Duration interstitialCooldown = Duration(minutes: 2);
  static const Duration fullscreenGlobalCooldown = Duration(seconds: 90);
  static const Duration appOpenMinimumBackgroundDuration = Duration(
    seconds: 90,
  );
  static const Duration appOpenCooldown = Duration(minutes: 15);
  static const int appOpenMinimumSessionCount = 1;
  static const int freeChapterCount = 3;
  static const int rewardedUnlockChapterCount = 2;
  static const int rewardedMaximumRetryCount = 3;
  static const int nativeFirstContentPosition = 4;
  static const int nativeContentInterval = 6;
}
