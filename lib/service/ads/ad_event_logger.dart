import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:flutter/foundation.dart';

abstract final class AdEventLogger {
  static void log(String event, AdPlacement placement) {
    if (kDebugMode) {
      debugPrint('AdMob $event: ${placement.analyticsName}');
    }
  }
}
