import 'package:book_brain/service/ads/ad_defaults.dart';

abstract final class InlineAdListHelper {
  static int getDisplayItemCount(int contentLength) {
    if (contentLength < 5) return contentLength;
    return contentLength + _adCount(contentLength);
  }

  static bool isAdDisplayIndex(int displayIndex, int contentLength) {
    if (contentLength < 5 ||
        displayIndex < AdDefaults.nativeFirstContentPosition) {
      return false;
    }
    return (displayIndex - AdDefaults.nativeFirstContentPosition) %
            (AdDefaults.nativeContentInterval + 1) ==
        0;
  }

  static int getContentIndex(int displayIndex) {
    if (displayIndex < AdDefaults.nativeFirstContentPosition) {
      return displayIndex;
    }
    final adsBefore =
        ((displayIndex - AdDefaults.nativeFirstContentPosition) ~/
            (AdDefaults.nativeContentInterval + 1)) +
        1;
    return displayIndex - adsBefore;
  }

  static int _adCount(int contentLength) =>
      1 +
      ((contentLength - AdDefaults.nativeFirstContentPosition) ~/
          AdDefaults.nativeContentInterval);
}
