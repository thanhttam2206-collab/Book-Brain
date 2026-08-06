import 'package:book_brain/utils/core/helpers/local_storage_helper.dart';

abstract final class AdAvailability {
  static bool get adsEnabled => LocalStorageHelper.getValue('isAds') != 'off';
}
