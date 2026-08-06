abstract final class AdDefaults {
  static const int interstitialActionThreshold = 3;
  static const Duration interstitialCooldown = Duration(minutes: 3);
  static const Duration fullscreenGlobalCooldown = Duration(seconds: 90);
  static const Duration appOpenMinimumBackgroundDuration = Duration(
    seconds: 90,
  );
  static const Duration appOpenCooldown = Duration(minutes: 15);
  static const int appOpenMinimumSessionCount = 3;
  static const int freeChapterCount = 3;
  static const int rewardedUnlockChapterCount = 2;
  static const int rewardedMaximumRetryCount = 3;
  static const int nativeFirstContentPosition = 4;
  static const int nativeContentInterval = 6;
}
