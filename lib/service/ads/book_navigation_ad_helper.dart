import 'package:book_brain/screen/preview/view/preview_screen.dart';
import 'package:book_brain/service/ads/ad_frequency_manager.dart';
import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/service/service_config/admob_service.dart';
import 'package:flutter/material.dart';

abstract final class BookNavigationAdHelper {
  static bool _navigationLocked = false;

  static Future<void> openBookPreviewWithAd({
    required BuildContext context,
    required int bookId,
    required AdPlacement sourcePlacement,
  }) async {
    if (_navigationLocked) return;
    _navigationLocked = true;
    try {
      AdFrequencyManager.instance.registerContentAction();
      await AdMobService.instance.showInterstitialIfEligible(
        placement: AdPlacement.contentNavigationInterstitial,
      );
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PreviewScreen(bookId: bookId),
          settings: RouteSettings(name: sourcePlacement.analyticsName),
        ),
      );
    } finally {
      _navigationLocked = false;
    }
  }
}
