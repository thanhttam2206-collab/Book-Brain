import 'package:book_brain/service/ads/ad_availability.dart';
import 'package:book_brain/service/ads/ad_frequency_manager.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/service/ads/app_open_ad_manager.dart';
import 'package:book_brain/service/ads/interstitial_ad_manager.dart';
import 'package:book_brain/service/ads/rewarded_ad_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  AdMobService._internal()
    : _interstitial = InterstitialAdManager(
        adUnitId: () => instance.getAdUnitId('interstitial'),
      ),
      _rewarded = RewardedAdManager(
        rewardedAdUnitId: () => instance.getAdUnitId('rewarded'),
        rewardedInterstitialAdUnitId:
            () => instance.getAdUnitId('rewarded_interstitial'),
      ),
      _appOpen = AppOpenAdManager(
        adUnitId: () => instance.getAdUnitId('app_open'),
      );

  static final AdMobService instance = AdMobService._internal();
  factory AdMobService() => instance;

  static const String appId = 'ca-app-pub-4649011658078977~9956099225';

  static const Map<String, String> _testAdUnitIds = {
    'banner': 'ca-app-pub-3940256099942544/6300978111',
    'interstitial': 'ca-app-pub-3940256099942544/1033173712',
    'rewarded': 'ca-app-pub-3940256099942544/5224354917',
    'rewarded_interstitial': 'ca-app-pub-3940256099942544/5354046379',
    'native': 'ca-app-pub-3940256099942544/2247696110',
    'app_open': 'ca-app-pub-3940256099942544/3419835294',
  };

  static const Map<String, String> _productionAdUnitIds = {
    'banner': 'ca-app-pub-4649011658078977/9470907708',
    'interstitial': 'ca-app-pub-4649011658078977/2972560925',
    'rewarded': 'ca-app-pub-4649011658078977/1060713457',
    'rewarded_interstitial': 'ca-app-pub-4649011658078977/1970470448',
    'native': 'ca-app-pub-4649011658078977/7594332217',
    'app_open': 'ca-app-pub-4649011658078977/2465294465',
  };

  final InterstitialAdManager _interstitial;
  final RewardedAdManager _rewarded;
  final AppOpenAdManager _appOpen;
  bool _isInitialized = false;

  bool get adsEnabled => AdAvailability.adsEnabled;

  String getAdUnitId(String type) {
    final ids = kReleaseMode ? _productionAdUnitIds : _testAdUnitIds;
    return ids[type] ?? '';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    AdFrequencyManager.instance.registerSession();
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (_) {
      // Ad initialization must never prevent the app from starting.
    }
  }

  Future<void> preloadInterstitial() => _interstitial.preload();

  Future<bool> showInterstitialIfEligible({required AdPlacement placement}) =>
      _interstitial.showIfEligible(placement: placement);

  Future<void> preloadRewarded() => _rewarded.preloadRewarded();

  Future<RewardedAdResult> showRewarded({required AdPlacement placement}) =>
      _rewarded.showRewarded(placement: placement);

  Future<RewardedAdResult> showRewardedInterstitial({
    required AdPlacement placement,
  }) async {
    await _rewarded.preloadRewardedInterstitial();
    return _rewarded.showRewardedInterstitial(placement: placement);
  }

  Future<void> preloadAppOpen() => _appOpen.preload();
  Future<bool> showAppOpenIfEligible() => _appOpen.showIfEligible();

  // Compatibility aliases for legacy callers while placements are migrated.
  Future<void> loadInterstitialAd() => preloadInterstitial();
  Future<void> loadRewardedAd() => preloadRewarded();
  Future<void> loadAppOpenAd() => preloadAppOpen();

  void dispose() {
    _interstitial.dispose();
    _rewarded.dispose();
    _appOpen.dispose();
  }
}
