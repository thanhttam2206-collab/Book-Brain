import 'package:book_brain/service/ads/ad_defaults.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/service/ads/rewarded_ad_manager.dart';
import 'package:book_brain/service/service_config/admob_service.dart';
import 'package:book_brain/utils/core/helpers/local_storage_helper.dart';

enum ChapterAccessResult {
  granted,
  grantedByReward,
  denied,
  temporarilyGrantedAfterAdFailure,
}

class ChapterAdGate {
  ChapterAdGate._();

  static final ChapterAdGate instance = ChapterAdGate._();
  Future<ChapterAccessResult>? _activeRequest;

  Future<ChapterAccessResult> requestAccess({
    required int bookId,
    required int chapterNumber,
  }) {
    if (!AdMobService.instance.adsEnabled ||
        chapterNumber <= AdDefaults.freeChapterCount ||
        _isUnlocked(bookId, chapterNumber)) {
      return Future.value(ChapterAccessResult.granted);
    }
    if (_activeRequest != null) {
      return Future.value(ChapterAccessResult.denied);
    }
    final request = _requestReward(bookId, chapterNumber);
    _activeRequest = request;
    return request.whenComplete(() => _activeRequest = null);
  }

  Future<ChapterAccessResult> _requestReward(
    int bookId,
    int chapterNumber,
  ) async {
    for (
      var attempt = 0;
      attempt < AdDefaults.rewardedMaximumRetryCount;
      attempt++
    ) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }
      await AdMobService.instance.preloadRewarded();
      final result = await AdMobService.instance.showRewarded(
        placement: AdPlacement.chapterUnlock,
      );
      if (result == RewardedAdResult.rewarded) {
        _unlock(bookId, chapterNumber);
        return ChapterAccessResult.grantedByReward;
      }
      if (result == RewardedAdResult.closedEarly) {
        return ChapterAccessResult.denied;
      }
    }
    return ChapterAccessResult.temporarilyGrantedAfterAdFailure;
  }

  bool _isUnlocked(int bookId, int chapterNumber) {
    final stored = LocalStorageHelper.getValue(_storageKey(bookId));
    return stored is List && stored.whereType<int>().contains(chapterNumber);
  }

  void _unlock(int bookId, int chapterNumber) {
    final key = _storageKey(bookId);
    final stored = LocalStorageHelper.getValue(key);
    final chapters = <int>{if (stored is List) ...stored.whereType<int>()};
    for (
      var offset = 0;
      offset < AdDefaults.rewardedUnlockChapterCount;
      offset++
    ) {
      chapters.add(chapterNumber + offset);
    }
    final sorted = chapters.toList()..sort();
    LocalStorageHelper.setValue(key, sorted);
  }

  String _storageKey(int bookId) => 'reward_unlocked_chapters_$bookId';
}
