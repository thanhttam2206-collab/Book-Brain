# SPEC HOÀN CHỈNH NÂNG CẤP ADMOB CHO BOOK BRAIN

## 1. Bối cảnh

Repository:

```text
https://github.com/NguyenMinhDuc163/Book-Brain
```

Đây là ứng dụng Flutter đọc sách miễn phí, đã tích hợp AdMob và đang có các loại quảng cáo:

```text
banner
native
interstitial
rewarded
rewarded_interstitial
app_open
```

Hệ thống hiện tại đã có:

* AdMob App ID.
* Ad Unit ID thật.
* Ad Unit ID test.
* Firebase Remote Config.
* Cơ chế server hoặc cấu hình hiện tại cập nhật biến `isAds`.
* Base URL server hiện có.
* Các URL hỗ trợ, chính sách và thông tin ứng dụng hiện có.

Quảng cáo hiện được đặt khá rời rạc, một số màn hình tự tải và tự quản lý quảng cáo, chưa có quy tắc tần suất thống nhất.

Agent phải refactor toàn bộ hệ thống quảng cáo và triển khai các vị trí quảng cáo mới trong một lần hoàn chỉnh.

---

# 2. Mục tiêu

Nâng cấp hệ thống AdMob theo hướng:

* Hiển thị nhiều quảng cáo nhất có thể trong luồng sử dụng hợp lý.
* Không đặt quảng cáo ngẫu nhiên sau mọi thao tác.
* Không hiển thị nhiều quảng cáo toàn màn hình liên tiếp.
* Tăng impression thông qua banner và native ads.
* Tăng doanh thu thông qua interstitial và rewarded ads.
* Không làm người dùng bị khóa vĩnh viễn khi quảng cáo lỗi.
* Không tạo thêm Ad Unit ID.
* Không thêm các tham số Remote Config mới.
* Không thay đổi URL server hoặc base URL hiện tại.
* Không thay đổi cách server hiện tại bật/tắt quảng cáo.
* Không thay đổi các nghiệp vụ ngoài phạm vi quảng cáo.
* Chỉ chạy format và static analysis.
* Không build Android hoặc iOS.

---

# 3. Nguyên tắc cấu hình quảng cáo

## 3.1. Không thêm tham số Remote Config

Không tạo hoặc sử dụng các Remote Config key mới như:

```text
interstitial_action_threshold
interstitial_cooldown_seconds
free_chapter_count
native_item_interval
app_open_cooldown_seconds
reward_unlock_chapter_count
```

Toàn bộ các giá trị này phải là hằng số mặc định trong code.

Không yêu cầu người quản trị phải cấu hình thủ công thêm tham số nào trên Firebase.

Không tạo màn hình cấu hình quảng cáo mới.

Không tạo API cấu hình quảng cáo mới.

---

## 3.2. Chỉ phụ thuộc biến bật/tắt quảng cáo hiện có

Toàn bộ quảng cáo chỉ được phép hoạt động khi biến hiện tại cho phép.

Giữ nguyên cách kiểm tra tương đương:

```dart
LocalStorageHelper.getValue('isAds') != 'off'
```

Quy tắc:

```text
isAds == 'off'
→ tắt toàn bộ quảng cáo

isAds khác 'off', null hoặc trạng thái bật hiện có
→ bật toàn bộ hệ thống quảng cáo
```

Agent phải kiểm tra luồng hiện tại mà server hoặc Firebase Remote Config đang dùng để cập nhật `isAds`.

Giữ nguyên luồng đó.

Không đổi tên biến `isAds`.

Không thay đổi kiểu dữ liệu đang dùng cho `isAds`.

Không tạo thêm các biến bật/tắt riêng cho:

```text
banner
native
interstitial
rewarded
app_open
```

Khi quảng cáo được bật, mặc định bật tất cả loại quảng cáo theo quy tắc trong spec này.

---

## 3.3. Giữ nguyên URL cũ

Không được thay đổi:

* Base URL server.
* Firebase Remote Config base URL.
* URL API.
* Endpoint API.
* URL hỗ trợ.
* URL privacy policy.
* URL điều khoản.
* URL GitHub.
* URL hình ảnh.
* Network image URL.
* Bất kỳ URL production hiện có nào.

Không được tạo URL mới để phục vụ quảng cáo.

Không chỉnh sửa `FirebaseService.getBaseURLServer()` ngoài trường hợp cần sửa lỗi biên dịch trực tiếp liên quan đến refactor, và không được thay đổi giá trị hoặc nghiệp vụ trả về.

Không đổi `.env`.

Không đổi cấu hình network.

---

# 4. Giữ nguyên AdMob ID hiện có

Tiếp tục sử dụng các key trong:

```text
lib/service/service_config/admob_service.dart
```

Bao gồm:

```dart
'banner'
'interstitial'
'rewarded'
'rewarded_interstitial'
'native'
'app_open'
```

Không tạo thêm Ad Unit ID theo màn hình.

Không tạo các key dạng:

```text
home_banner
search_banner
reading_banner
home_native
search_native
```

Một Ad Unit ID có thể được dùng lại tại nhiều placement cùng loại.

Giữ nguyên toàn bộ production Ad Unit ID hiện tại.

Giữ nguyên toàn bộ Google test Ad Unit ID hiện tại.

Giữ nguyên nguyên tắc:

```dart
kReleaseMode
```

* Release dùng production ID.
* Debug và profile dùng test ID.

Không được để debug hoặc profile gọi quảng cáo production.

Không log production Ad Unit ID.

---

# 5. Các giá trị mặc định cố định trong code

Tạo một class chứa các hằng số quảng cáo, ví dụ:

```dart
abstract final class AdDefaults
```

Hoặc tên tương đương.

Các giá trị phải được cố định như sau:

```dart
static const int interstitialActionThreshold = 3;

static const Duration interstitialCooldown =
    Duration(minutes: 3);

static const Duration fullscreenGlobalCooldown =
    Duration(seconds: 90);

static const Duration appOpenMinimumBackgroundDuration =
    Duration(seconds: 90);

static const Duration appOpenCooldown =
    Duration(minutes: 15);

static const int appOpenMinimumSessionCount = 3;

static const int freeChapterCount = 3;

static const int rewardedUnlockChapterCount = 2;

static const int rewardedMaximumRetryCount = 3;

static const int nativeFirstContentPosition = 4;

static const int nativeContentInterval = 6;
```

Các giá trị này không lấy từ Remote Config.

Các giá trị này không lấy từ server.

Server chỉ quyết định quảng cáo bật hay tắt thông qua `isAds`.

---

# 6. Kiến trúc mới

Tổ chức lại hệ thống quảng cáo theo cấu trúc tương đương:

```text
lib/
  service/
    service_config/
      admob_service.dart

    ads/
      ad_defaults.dart
      ad_placement.dart
      ad_frequency_manager.dart
      ad_event_logger.dart
      app_open_ad_manager.dart
      interstitial_ad_manager.dart
      rewarded_ad_manager.dart
      chapter_ad_gate.dart
      inline_ad_list_helper.dart
      book_navigation_ad_helper.dart

  widgets/
    ads/
      adaptive_banner_ad_widget.dart
      native_book_ad_widget.dart
```

Có thể điều chỉnh tên file theo conventions của repository, nhưng phải phân tách đúng trách nhiệm.

Không bắt buộc tạo quá nhiều class nhỏ nếu làm code phức tạp không cần thiết. Tuy nhiên tối thiểu phải có:

* Service/facade quảng cáo chung.
* Frequency manager.
* Chapter ad gate.
* Adaptive banner widget.
* Native ad widget.
* Navigation helper dùng interstitial.
* Inline list helper.

---

# 7. Quy tắc dependency

Không thêm package mới nếu chưa bắt buộc.

Tiếp tục dùng:

```text
google_mobile_ads
firebase_remote_config
hive_ce_flutter
```

Không thêm package state management mới.

Không thêm package analytics mới.

Không thêm package consent mới trong task này.

Không nâng version package nếu không cần để code biên dịch tĩnh.

Không chạy `flutter pub upgrade`.

Không sửa `pubspec.lock` ngoài trường hợp công cụ tự thay đổi bắt buộc, nhưng do không thêm dependency nên không nên có thay đổi.

---

# 8. AdPlacement

Tạo enum định danh vị trí quảng cáo:

```dart
enum AdPlacement {
  appResume,

  homeAfterTrending,
  homeFooter,

  allBooksInline,

  searchLandingFooter,
  searchResultsInline,

  favoritesInline,
  historyInline,
  followingInline,

  rankingAuthorsInline,
  rankingBooksInline,

  previewBookInline,

  readingChapterEndBanner,
  readingChapterEndNative,

  chapterUnlock,

  contentNavigationInterstitial,
}
```

Tạo extension:

```dart
extension AdPlacementX on AdPlacement {
  String get analyticsName;
}
```

Không viết placement bằng chuỗi rải rác trong nhiều màn hình.

Mọi ad request phải truyền placement tương ứng nếu kiến trúc hỗ trợ.

---

# 9. Kiểm tra bật/tắt quảng cáo

Tạo getter dùng chung, ví dụ:

```dart
bool get adsEnabled {
  return LocalStorageHelper.getValue('isAds') != 'off';
}
```

Tất cả manager và widget phải dùng cùng một nguồn kiểm tra.

Không copy điều kiện `isAds` ở nhiều nơi nếu có thể tránh.

Khi `isAds == 'off'`:

* Không load banner.
* Không load native.
* Không preload interstitial.
* Không preload rewarded.
* Không preload app open.
* Không hiển thị slot quảng cáo.
* Chapter gate phải cấp quyền đọc trực tiếp.
* Không làm thay đổi layout bằng placeholder quảng cáo.
* Không retry quảng cáo.

Khi `isAds` được bật trở lại trong một phiên mới:

* Hệ thống quảng cáo hoạt động bình thường.
* Không cần người dùng cấu hình thêm gì.

---

# 10. AdFrequencyManager

Tạo singleton quản lý tần suất quảng cáo toàn màn hình.

Trạng thái tối thiểu:

```dart
DateTime? lastFullscreenAdShownAt;
DateTime? lastInterstitialShownAt;
DateTime? lastAppOpenShownAt;
DateTime? backgroundStartedAt;

int contentActionCount;
int sessionCount;

bool isFullscreenAdShowing;
```

Các hàm tối thiểu:

```dart
void registerContentAction();

bool canShowInterstitial();

bool canShowAppOpen();

bool canShowRewarded();

void markFullscreenAdStarted(AdPlacement placement);

void markFullscreenAdFinished(AdPlacement placement);

void resetContentActionCount();

void onAppBackgrounded();

void onAppForegrounded();
```

Không lưu `BuildContext` trong manager.

Không phụ thuộc vào màn hình cụ thể.

---

# 11. Global full-screen rule

Các loại sau được coi là full-screen ad:

```text
interstitial
rewarded
rewarded interstitial
app open
```

Không hiển thị full-screen ad mới nếu:

```text
full-screen ad khác đang hiển thị
```

Sau khi một full-screen ad kết thúc, không tự động hiển thị full-screen ad khác trong vòng:

```text
90 giây
```

Ngoại lệ duy nhất:

* Người dùng chủ động yêu cầu mở khóa chương bằng rewarded.
* Tuy nhiên nếu vừa xem một full-screen ad khác trong vài giây trước đó, vẫn không được show rewarded ngay.
* Chapter gate phải giữ người dùng ở màn hình hiện tại và cho phép họ thử lại sau, hoặc ưu tiên không show interstitial trước chapter gate để tránh xung đột này.

Thiết kế luồng phải bảo đảm interstitial không xuất hiện ngay trước rewarded chapter unlock.

---

# 12. Interstitial frequency

Interstitial chỉ được hiển thị khi đồng thời:

```text
ads đang bật
AND
contentActionCount >= 3
AND
ít nhất 3 phút từ interstitial gần nhất
AND
ít nhất 90 giây từ full-screen ad gần nhất
AND
không có full-screen ad đang hiển thị
AND
interstitial đã load
```

Sau khi interstitial bắt đầu hiển thị:

```dart
contentActionCount = 0;
```

Nếu interstitial chưa load hoặc load lỗi:

* Không chặn navigation.
* Navigation tiếp tục ngay.
* Preload lại sau.

---

# 13. Content action

Một content action được tính khi người dùng mở một cuốn sách từ:

* Trang chủ.
* Danh sách tất cả sách.
* Kết quả tìm kiếm.
* Yêu thích.
* Sách theo dõi.
* Lịch sử đọc nếu mở PreviewScreen.
* Bảng xếp hạng sách.

Không tính content action khi:

* Đổi bottom tab.
* Mở SearchScreen.
* Submit tìm kiếm.
* Mở NotificationScreen.
* Mở Settings.
* Mở login.
* Mở signup.
* Mở forgot password.
* Nhấn yêu thích.
* Nhấn theo dõi.
* Nhấn Back.
* Đổi tab tác giả/sách trong ranking.
* Mở thông tin hỗ trợ.
* Mở privacy policy.
* Đăng xuất.
* Xóa tài khoản.

---

# 14. AdMobService

Refactor `AdMobService` thành facade quảng cáo chung.

API mong muốn:

```dart
class AdMobService {
  static final AdMobService instance = AdMobService._internal();

  Future<void> initialize();

  bool get adsEnabled;

  String getAdUnitId(String type);

  Future<void> preloadInterstitial();

  Future<bool> showInterstitialIfEligible({
    required AdPlacement placement,
  });

  Future<void> preloadRewarded();

  Future<RewardedAdResult> showRewarded({
    required AdPlacement placement,
  });

  Future<RewardedAdResult> showRewardedInterstitial({
    required AdPlacement placement,
  });

  Future<void> preloadAppOpen();

  Future<bool> showAppOpenIfEligible();

  void dispose();
}
```

Có thể giữ factory constructor hiện tại để không phá code:

```dart
factory AdMobService() => _instance;
```

Nhưng code mới nên dùng thống nhất một cách gọi.

Tất cả quảng cáo full-screen phải được preload.

Sau khi quảng cáo đóng hoặc lỗi show:

* Dispose ad.
* Set instance về null.
* Cập nhật frequency manager.
* Preload ad mới nếu ads vẫn đang bật.

---

# 15. Chống duplicate load

Mỗi manager phải có trạng thái chống tải trùng:

```dart
bool _isLoadingInterstitial = false;
bool _isLoadingRewarded = false;
bool _isLoadingRewardedInterstitial = false;
bool _isLoadingAppOpen = false;
```

Không thực hiện load mới khi:

* Đã có quảng cáo sẵn sàng.
* Đang load quảng cáo cùng loại.
* Ads đang bị tắt.

Không tạo nhiều rewarded ad cùng lúc.

Không tạo nhiều interstitial cùng lúc.

Không tạo nhiều app open ad cùng lúc.

---

# 16. App Open Ad

Dùng key hiện có:

```text
app_open
```

Tích hợp lifecycle bằng `WidgetsBindingObserver` tại cấp ứng dụng hoặc `MainApp`.

## Không hiển thị khi cold start

Không show app open trong:

* SplashScreen.
* Lần đầu ứng dụng khởi động.
* Ngay sau SplashScreen.
* Trước khi người dùng thấy MainApp.

## Session count

Lưu session count bằng LocalStorage.

Mỗi lần cold start:

```dart
sessionCount += 1;
```

Không tăng session count mỗi lần app resume.

Chỉ bắt đầu cho phép app open từ session thứ 3.

## Khi background

Khi app chuyển sang background:

```dart
AdFrequencyManager.instance.onAppBackgrounded();
AdMobService.instance.preloadAppOpen();
```

## Khi foreground

Chỉ show nếu:

```text
ads đang bật
AND
sessionCount >= 3
AND
app đã nằm background ít nhất 90 giây
AND
app open gần nhất cách ít nhất 15 phút
AND
full-screen ad gần nhất cách ít nhất 90 giây
AND
không có full-screen ad khác đang hiển thị
AND
app open ad đã load
```

Nếu không đủ điều kiện:

* Không show.
* Không chặn app foreground.

Nếu load/show lỗi:

* Bỏ qua.
* Dispose đúng.
* Preload lại sau.

Không cố show app open khi người dùng quay lại từ Google Sign-In hoặc browser nếu global cooldown chưa đủ.

---

# 17. Adaptive Banner Widget

Refactor hoặc thay thế:

```text
lib/widgets/ad_banner_widget.dart
```

Bằng widget adaptive banner.

Tên đề xuất:

```text
lib/widgets/ads/adaptive_banner_ad_widget.dart
```

API:

```dart
AdaptiveBannerAdWidget(
  placement: AdPlacement.homeFooter,
)
```

Widget phải:

* Kiểm tra `adsEnabled`.
* Dùng anchored adaptive banner theo chiều rộng màn hình.
* Tính kích thước sau khi layout có width hợp lệ.
* Không load khi width bằng 0.
* Dispose banner đúng lifecycle.
* Không reuse `AdWidget` với ad instance khác.
* Không có nút đóng quảng cáo custom.
* Không có overlay lên quảng cáo.
* Không hiển thị thông báo lỗi.
* Không hiển thị spinner vô hạn.
* Khi ad chưa load có thể giữ khoảng trống rất nhỏ hoặc collapse.
* Khi ad load lỗi phải collapse hoàn toàn.
* Không tự refresh banner trong code.
* Dùng key `banner` hiện có.

Xóa toàn bộ logic tương đương:

```dart
_hideBannerAd()
_bannerHiddenTime
_bannerHideDuration
```

---

# 18. Native Ad Widget

Tạo widget:

```dart
NativeBookAdWidget(
  placement: AdPlacement.searchResultsInline,
)
```

Yêu cầu:

* Mỗi widget tạo một NativeAd instance riêng.
* Không dùng chung một NativeAd instance trên nhiều vị trí.
* Dùng key `native` hiện có.
* Giữ `factoryId: 'listTile'` nếu đây là factory đang có.
* Không thay đổi factory ID khi chưa cần.
* Dispose đúng lifecycle.
* Không hiển thị error text.
* Không hiển thị spinner lâu.
* Nếu load lỗi thì collapse.
* Không có overlay che quảng cáo.
* Không đặt nút ứng dụng đè lên vùng quảng cáo.
* Không lưu `BuildContext` trong controller.

Agent phải kiểm tra tĩnh việc đăng ký native factory trên Android và iOS.

Không sửa native factory nếu không cần.

Nếu iOS không có factory tương ứng nhưng quảng cáo iOS hiện đang tắt bằng hệ thống cũ, không được tự tạo một implementation lớn không thể validate bằng build. Chỉ báo cáo lại trong kết quả.

---

# 19. InlineAdListHelper

Tạo helper dùng chung để xen native ad vào danh sách.

Quy tắc:

```text
Danh sách dưới 5 item
→ không chèn native ad

Quảng cáo đầu tiên
→ sau 4 item nội dung

Các quảng cáo tiếp theo
→ sau mỗi 6 item nội dung
```

Ví dụ:

```text
Sách 1
Sách 2
Sách 3
Sách 4
Native Ad
Sách 5
Sách 6
Sách 7
Sách 8
Sách 9
Sách 10
Native Ad
```

Helper phải hỗ trợ:

```dart
int getDisplayItemCount(int contentLength);

bool isAdDisplayIndex(int displayIndex, int contentLength);

int getContentIndex(int displayIndex);
```

Không để mỗi màn hình tự viết công thức riêng.

Không làm sai index khi xóa hoặc cập nhật sách.

Không để ad item được tính là dữ liệu API.

Không để pagination dựa vào display item count.

---

# 20. Book navigation interstitial helper

Tạo helper dùng chung:

```dart
Future<void> openBookPreviewWithAd({
  required BuildContext context,
  required int bookId,
  required AdPlacement sourcePlacement,
});
```

Luồng:

```text
Kiểm tra navigation lock
→ registerContentAction()
→ showInterstitialIfEligible()
→ sau khi ad đóng, lỗi hoặc không đủ điều kiện
→ mở PreviewScreen
```

Yêu cầu:

* Navigation luôn tiếp tục nếu quảng cáo lỗi.
* Không mở PreviewScreen hai lần.
* Không show hai interstitial do double tap.
* Không giữ `BuildContext` trong singleton.
* Kiểm tra `context.mounted` trước navigation sau await.
* Có lock chống double tap.
* Lock được giải phóng khi flow hoàn thành.

Interstitial phải xuất hiện trước navigation, không xuất hiện sau khi PreviewScreen đã mở.

---

# 21. Rewarded result

Tạo enum hoặc result class:

```dart
enum RewardedAdResult {
  rewarded,
  closedEarly,
  unavailable,
  failedToShow,
}
```

Hoặc cấu trúc tương đương.

Phải phân biệt:

* Người dùng nhận reward.
* Người dùng đóng sớm.
* Ad không load.
* Ad không show được.

Không cấp quyền khi chỉ có callback dismiss.

Chỉ cấp quyền khi `onUserEarnedReward` được gọi.

---

# 22. ChapterAdGate

Tạo singleton hoặc service:

```dart
class ChapterAdGate
```

Đây là nơi duy nhất xử lý quyền truy cập chương thông qua quảng cáo.

`PreviewScreen` và `DetailBookScreen` không được tự load rewarded.

## Quy tắc chương miễn phí

Cố định trong code:

```text
Chương 1, 2, 3 được đọc miễn phí.
```

Điều kiện:

```dart
chapterNumber <= AdDefaults.freeChapterCount
```

## Quy tắc mở khóa

Cố định:

```text
1 rewarded ad mở khóa 2 chương liên tiếp.
```

Ví dụ:

```text
Xem ad cho chương 4
→ mở khóa chương 4 và 5

Xem ad cho chương 6
→ mở khóa chương 6 và 7
```

Không yêu cầu rewarded ở mọi chương.

## Key lưu trữ

Trạng thái mở khóa phải gắn với book ID.

Không dùng key chỉ chứa chapter number.

Có thể dùng:

```text
reward_unlocked_chapters_<bookId>
```

Hoặc map:

```dart
Map<String, List<int>>
```

Phải tránh trường hợp mở khóa chương 4 của sách A đồng thời mở chương 4 của sách B.

## Phạm vi lưu

Không reset unlock khi rời `DetailBookScreen`.

Không còn logic:

```dart
LocalStorageHelper.setValue(_viewedAdsChaptersKey, []);
```

trong `dispose`.

Trạng thái unlock phải được giữ trong LocalStorage.

Có thể giữ lâu dài để tránh bắt người dùng xem lại quảng cáo cho cùng chương.

Nếu muốn giới hạn theo phiên thì phải có session ID, nhưng spec này ưu tiên đơn giản và ổn định: lưu chapter unlock theo book bằng LocalStorage.

## API

```dart
Future<ChapterAccessResult> requestAccess({
  required int bookId,
  required int chapterNumber,
});
```

Kết quả:

```dart
enum ChapterAccessResult {
  granted,
  grantedByReward,
  denied,
  temporarilyGrantedAfterAdFailure,
}
```

---

# 23. Chapter gate flow

Luồng bắt buộc:

```text
Ads đang tắt?
→ granted

Chương <= 3?
→ granted

Chương đã được mở khóa?
→ granted

Rewarded request khác đang chạy?
→ dùng chung Future hiện tại hoặc từ chối request trùng

Rewarded chưa load?
→ thử load

Load thành công?
→ show rewarded

Người dùng nhận reward?
→ mở khóa chương hiện tại và chương kế tiếp
→ grantedByReward

Người dùng đóng sớm?
→ denied

Load/show lỗi hoàn toàn?
→ temporarilyGrantedAfterAdFailure
```

Không được coi dismiss là reward.

Không được điều hướng khi result là `denied`.

---

# 24. Rewarded retry

Số lần thử tối đa:

```text
3 lần
```

Backoff:

```text
Lần 1: thử ngay.
Lần 2: chờ 1 giây.
Lần 3: chờ 2 giây.
```

Không dùng vòng `while` kết hợp callback mà không await được kết quả thật.

Có thể dùng:

* `Completer`.
* Hàm load trả về Future.
* Vòng for với await.
* Recursive retry có giới hạn.

Phải chống callback cũ hoàn thành sau khi request mới đã bắt đầu.

---

# 25. Rewarded error fallback

Nếu rewarded không thể load hoặc show sau 3 lần:

* Cho phép người dùng đọc đúng chương đang yêu cầu.
* Không mở khóa chương kế tiếp.
* Không lưu chương đó vào danh sách unlock lâu dài.
* Trả về:

```dart
ChapterAccessResult.temporarilyGrantedAfterAdFailure
```

Có thể hiển thị SnackBar:

```text
Không thể tải quảng cáo. Bạn có thể tiếp tục đọc chương này.
```

Không hiển thị stack trace hoặc mã lỗi AdMob.

Không khóa người dùng vô hạn.

---

# 26. Rewarded Interstitial

Giữ nguyên key:

```text
rewarded_interstitial
```

Không xóa manager hoặc hỗ trợ hiện có nếu có thể giữ an toàn.

Tuy nhiên trong nghiệp vụ mới:

* Không dùng rewarded interstitial để mở khóa chương.
* Không tự động show rewarded interstitial.
* Không dùng rewarded interstitial trong các màn hình hiện tại.
* Dùng rewarded thông thường cho chapter unlock.

Key này được giữ để không phá hệ thống cũ hoặc để sử dụng trong tương lai.

Không thêm tham số bật/tắt riêng.

Không cần triển khai flow mới cho rewarded interstitial ngoài việc giữ service an toàn và không có dead code lỗi analyze.

Nếu code cũ chỉ dùng rewarded interstitial ở PreviewScreen thì xóa flow đó và thay bằng ChapterAdGate dùng rewarded.

---

# 27. HomeScreen

File:

```text
lib/screen/home/view/home_screen.dart
```

Thực hiện:

## Sau Top thịnh hành

Thay banner hiện tại bằng:

```dart
NativeBookAdWidget(
  placement: AdPlacement.homeAfterTrending,
)
```

## Cuối trang Home

Giữ một adaptive banner:

```dart
AdaptiveBannerAdWidget(
  placement: AdPlacement.homeFooter,
)
```

Home chỉ có:

* Một native ad.
* Một adaptive banner.

Không đặt hai banner như hiện tại.

## Mở sách

Mọi book card trên Home phải dùng navigation helper có interstitial.

Không điều hướng trực tiếp đến PreviewScreen nếu helper có thể áp dụng.

## Không dùng interstitial khi mở

* Search.
* Notification.
* History.
* Ranking.
* Following.
* Bottom tabs.

---

# 28. AllBookScreen

File:

```text
lib/screen/home/view/all_book_screen.dart
```

Chèn native ad:

* Sau 4 sách.
* Sau đó mỗi 6 sách.

Placement:

```dart
AdPlacement.allBooksInline
```

Khi mở sách:

* Dùng `openBookPreviewWithAd`.

Nếu layout là list:

* Native chiếm chiều ngang của list.

Nếu layout là grid:

* Ưu tiên native full-width giữa các hàng.
* Có thể dùng sliver để hỗ trợ full-span.
* Nếu thay grid sang cấu trúc phức tạp gây nguy cơ lỗi tĩnh, có thể hiển thị native như một grid item nhưng phải giữ đúng index.
* Không phá UI sách.
* Không phá scroll.
* Không phá empty state.

---

# 29. SearchScreen

File:

```text
lib/screen/search_screen/view/search_screen.dart
```

Giữ một adaptive banner ở cuối:

```dart
AdaptiveBannerAdWidget(
  placement: AdPlacement.searchLandingFooter,
)
```

Không thêm native khác trên màn nhập tìm kiếm.

Không hiển thị interstitial khi submit từ khóa.

Không hiển thị ad che keyboard.

Xóa import quảng cáo không còn dùng.

---

# 30. SearchResultScreen

File:

```text
lib/screen/search_screen/view/search_result_screen.dart
```

Chèn native ad:

* Sau kết quả thứ 4.
* Sau đó mỗi 6 kết quả.

Placement:

```dart
AdPlacement.searchResultsInline
```

Khi mở sách:

* Dùng navigation helper có interstitial.

Pagination:

* Không tính native ad là kết quả API.
* `loadMore` vẫn dựa trên trạng thái nội dung.
* Không trigger `loadMore` sớm do display list dài hơn.
* Không làm sai content index.
* Không làm sai empty state.

---

# 31. FavoritesScreen

File:

```text
lib/screen/favorites/view/favorites_screen.dart
```

Chỉ hiển thị ad khi:

```text
Người dùng đã đăng nhập.
Danh sách favorites không rỗng.
```

Chèn native:

* Sau 4 sách.
* Sau đó mỗi 6 sách.

Placement:

```dart
AdPlacement.favoritesInline
```

Hỗ trợ cả:

* Grid view.
* List view.

Không hiển thị ad trong:

* Login required view.
* Empty state.
* Search empty state.

Khi mở sách:

* Dùng navigation helper có interstitial.

Không thêm banner cố định nếu đã có native xen kẽ.

---

# 32. HistoryReadingScreen

File:

```text
lib/screen/history_reading/view/history_reading_screen.dart
```

Chèn native:

```dart
AdPlacement.historyInline
```

Quy tắc:

* Sau 4 nội dung.
* Sau đó mỗi 6 nội dung.
* Không hiển thị trong empty state.

Nếu item mở PreviewScreen:

* Dùng navigation interstitial helper.

Nếu item mở thẳng DetailBookScreen/chapter:

* Không dùng interstitial.
* Để ChapterAdGate xử lý.
* Không được hiển thị interstitial rồi ngay sau đó rewarded.

---

# 33. FollowingBookScreen

File:

```text
lib/screen/following_book/view/following_book_screen.dart
```

Chèn native:

```dart
AdPlacement.followingInline
```

Quy tắc:

* Sau 4 sách.
* Sau đó mỗi 6 sách.
* Không hiển thị trong empty state.
* Không hiển thị trong login required state.

Mở PreviewScreen qua interstitial navigation helper.

---

# 34. RankingScreen

Files:

```text
lib/screen/ranking/view/ranking_screen.dart
lib/screen/ranking/view/book_ranking_screen.dart
```

## Tác giả

Không chèn quảng cáo trong top 3 podium.

Sau top 3 hoặc trước danh sách còn lại:

```dart
NativeBookAdWidget(
  placement: AdPlacement.rankingAuthorsInline,
)
```

Nếu tab tác giả chỉ hiển thị podium và không có danh sách tiếp theo, đặt native sau toàn bộ podium.

## Sách

Chèn native sau khoảng 5 sách hoặc dùng helper mặc định sau 4 sách nếu phù hợp layout.

Placement:

```dart
AdPlacement.rankingBooksInline
```

Khi mở sách:

* Dùng navigation interstitial helper.

Không show interstitial khi đổi tab Tác giả/Sách.

---

# 35. PreviewScreen

File:

```text
lib/screen/preview/view/preview_screen.dart
```

## Native

Giữ tối đa một native ad:

```dart
NativeBookAdWidget(
  placement: AdPlacement.previewBookInline,
)
```

Đặt sau mô tả hoặc gần danh sách chương.

Không đặt sát nút “Bắt đầu đọc” theo cách dễ gây click nhầm.

## Xóa rewarded flow cũ

Xóa logic trực tiếp:

```dart
RewardedInterstitialAd.load(...)
RewardedAd.load(...)
_showRewardedInterstitialAdAndContinue(...)
_pendingChapterNumber
_isRewardedLoading
retryCount
```

nếu các biến không còn dùng sau refactor.

## Nút Bắt đầu đọc

Khi bấm:

```text
Disable nút.
Gọi ChapterAdGate.requestAccess.
Nếu granted thì mở DetailBookScreen.
Nếu grantedByReward thì mở DetailBookScreen.
Nếu temporarilyGrantedAfterAdFailure thì mở DetailBookScreen.
Nếu denied thì giữ nguyên PreviewScreen.
Enable lại nút nếu vẫn ở màn hình.
```

Chống double tap.

Không show interstitial trước ChapterAdGate.

Không thay đổi:

* Favorite.
* Following.
* Review.
* Mô tả sách.
* Lựa chọn chương.
* Thông tin tác giả.
* Điểm đánh giá.

---

# 36. DetailBookScreen

File:

```text
lib/screen/detail_book/view/detail_book_screen.dart
```

Đây là phần cần refactor quan trọng nhất.

## Xóa logic rewarded cũ

Xóa hoặc thay thế:

```dart
RewardedAd.load(...)
_isRewardedLoading
_pendingChapterNumber
_viewedAdsChaptersKey
_hasViewedAdForChapter(...)
_markChapterAsViewed(...)
_handleChapterChange(...)
```

Nếu `_handleChapterChange` được giữ, nó phải chỉ gọi ChapterAdGate, không tự quản lý SDK.

## Không reset unlock khi dispose

Xóa:

```dart
LocalStorageHelper.setValue(_viewedAdsChaptersKey, []);
```

Không reset quyền chương khi rời màn hình.

## Hàm chuyển chương thống nhất

Tạo:

```dart
Future<void> _requestChapterChange(
  int newChapterNumber,
  int maximumChapterNumber,
)
```

Luồng:

```text
Kiểm tra chapter range.
Nếu ngoài range thì hiển thị toast hiện tại.
Nếu hợp lệ thì khóa thao tác chuyển chương.
Gọi ChapterAdGate.requestAccess.
Nếu access được cấp thì gọi _updateChapter.
Nếu denied thì giữ chapter cũ.
Mở khóa thao tác.
```

Mọi cách chuyển chương phải đi qua hàm này:

* Previous chapter.
* Next chapter.
* Chapter selector.
* FAB hoặc menu.
* Deep link nếu có.
* Chapter ban đầu nếu mở trực tiếp.
* History continue reading.

## Chương ban đầu

Nếu `DetailBookScreen` được mở trực tiếp với chương lớn hơn chương miễn phí:

* Phải kiểm tra ChapterAdGate.
* Không tải nội dung chương bị khóa trước khi access được cấp nếu có thể.
* Nếu kiến trúc notifier tải ngay trong `initState`, refactor để gọi gate trước rồi mới `getData`.
* Nếu user đóng rewarded sớm, quay lại màn trước hoặc giữ màn hình với trạng thái không tải nội dung.
* Không để nội dung chương bị khóa hiển thị trong nền phía sau rewarded dialog.

## Ghi chú

Không thay đổi nghiệp vụ ghi chú.

Không thay đổi:

* Chọn text.
* Lưu note.
* Font size.
* Background.
* Scroll.
* Chapter boundary toast.

---

# 37. Quảng cáo cuối chương

Tại cuối nội dung của mỗi chương:

## Chương lẻ

Hiển thị:

```dart
AdaptiveBannerAdWidget(
  placement: AdPlacement.readingChapterEndBanner,
)
```

## Chương chẵn

Hiển thị:

```dart
NativeBookAdWidget(
  placement: AdPlacement.readingChapterEndNative,
)
```

Không hiển thị cả hai trong cùng chương.

Không đặt banner cố định dưới màn hình.

Không đặt quảng cáo nổi che text.

Không đặt quảng cáo giữa đoạn văn.

Vị trí:

```text
Nội dung chương
→ quảng cáo
→ điều hướng chương trước/sau
```

Nếu bố cục hiện tại không cho phép chính xác, đặt quảng cáo sau phần nội dung chính và trước phần cuối màn hình.

Khi `isAds == 'off'`, slot phải biến mất hoàn toàn.

---

# 38. MainApp và lifecycle

File phù hợp:

```text
lib/screen/main_app.dart
```

Hoặc một lifecycle observer mới được khởi tạo từ `main.dart`.

Khi MainApp init:

```dart
AdMobService.instance.preloadInterstitial();
AdMobService.instance.preloadRewarded();
```

Chỉ preload nếu ads đang bật.

Khi app vào background:

```dart
AdFrequencyManager.instance.onAppBackgrounded();
AdMobService.instance.preloadAppOpen();
```

Khi app foreground:

```dart
AdFrequencyManager.instance.onAppForegrounded();
AdMobService.instance.showAppOpenIfEligible();
```

Dispose lifecycle observer đúng.

Không tạo nhiều lifecycle observer sau rebuild.

---

# 39. Main.dart

Giữ nguyên:

* Firebase initialization.
* Firebase Remote Config initialization.
* Base URL.
* Localization.
* Hive.
* Provider.
* Navigator.
* App Check.
* AdMob initialize.

Không thay đổi URL cũ.

Không tạo Remote Config defaults cho các tham số quảng cáo.

Không thêm các key quảng cáo mới vào Firebase Service.

## iOS

Hiện tại có thể đang có đoạn:

```dart
if (defaultTargetPlatform == TargetPlatform.iOS) {
  LocalStorageHelper.setValue('isAds', 'off');
}
```

Yêu cầu:

* Không tự ý xóa nếu đây là cơ chế phát hành hiện tại mà server đang phụ thuộc.
* Tuy nhiên đoạn này ghi đè biến server mỗi lần khởi động và làm iOS luôn tắt quảng cáo.
* Agent phải giữ hành vi cũ trừ khi có chỉ dẫn rõ ràng từ chủ dự án cho phép bật quảng cáo iOS.

Trong task này:

```text
Giữ nguyên hành vi bật/tắt quảng cáo theo hệ thống hiện tại.
Không thay đổi chính sách quảng cáo iOS.
```

Nếu đoạn hard-code đang tồn tại, giữ nguyên.

Agent phải ghi rõ trong báo cáo:

```text
iOS vẫn bị tắt quảng cáo theo logic hiện có trong main.dart.
```

Không tự quyết định bật iOS.

---

# 40. SplashScreen

Không đặt quảng cáo trong SplashScreen.

Không preload bắt buộc gây kéo dài splash.

Không show app open sau splash.

Giữ nguyên luồng guest/login hiện tại.

Không sửa thời gian splash ngoài nhu cầu trực tiếp để sửa lỗi.

---

# 41. Màn hình không đặt quảng cáo

Không thêm quảng cáo vào:

```text
LoginScreen
SignUpScreen
ForgotPasswordScreen
EditProfileScreen
ChangePasswordScreen
Delete account dialog
Logout dialog
Các form tài khoản
Google Sign-In flow
Privacy/terms content
```

Không show interstitial khi:

* Đăng nhập.
* Đăng ký.
* Đổi mật khẩu.
* Xóa tài khoản.
* Đăng xuất.
* Chỉnh sửa hồ sơ.
* Xác nhận thao tác tài khoản.

Có thể giữ tab Setting không quảng cáo để tạo vùng nghỉ.

---

# 42. NotificationScreen

Không bắt buộc thêm quảng cáo trong task này.

Không show full-screen ad khi mở notification.

Nếu màn hình hiện đang có ad thì giữ hợp lý, nhưng không thêm mới.

Không làm ảnh hưởng cập nhật trạng thái thông báo đã đọc.

---

# 43. AdEventLogger

Tạo abstraction nhẹ:

```dart
class AdEventLogger
```

Không thêm Firebase Analytics dependency.

Có thể dùng:

```dart
debugPrint(...)
```

Trong debug.

Event gợi ý:

```text
ad_request
ad_loaded
ad_impression
ad_clicked
ad_failed_to_load
ad_failed_to_show
ad_showed
ad_dismissed
reward_earned
reward_closed_early
chapter_temporary_access_after_ad_failure
```

Metadata:

```dart
placement
adType
```

Không log:

* Ad Unit ID production.
* Email.
* User ID.
* Book content.
* Note content.
* Access token.
* Base URL nếu không cần.

Trong release có thể giảm hoặc tắt debug logging.

---

# 44. Banner/native failure

Khi banner hoặc native load lỗi:

```dart
return const SizedBox.shrink();
```

Không hiển thị:

* “Không thể tải quảng cáo”.
* Mã lỗi.
* Placeholder xám cố định.
* Retry button.
* Spinner vô hạn.
* Snackbar.

Có thể retry khi widget được tạo lại tự nhiên.

Không tạo vòng retry liên tục trong widget.

---

# 45. Interstitial failure

Nếu interstitial:

* Chưa load.
* Load lỗi.
* Show lỗi.
* Bị dispose.

Thì:

* Navigation tiếp tục.
* Không hiện error UI.
* Preload lại một quảng cáo mới.
* Không tăng action count thêm lần nữa cho cùng thao tác.
* Không reset action count nếu ad chưa thực sự show.

Chỉ reset counter khi full-screen content đã bắt đầu show.

---

# 46. App Open failure

Nếu app open lỗi:

* Foreground app ngay.
* Không chặn UI.
* Không show dialog.
* Dispose ad lỗi.
* Preload lại sau.
* Không cập nhật `lastAppOpenShownAt` nếu ad chưa show.

---

# 47. Rewarded đóng sớm

Nếu người dùng đóng rewarded trước khi nhận reward:

* Không mở khóa chương.
* Không chuyển chương.
* Không lưu unlock.
* Hiển thị thông báo ngắn:

```text
Bạn cần xem hết quảng cáo để tiếp tục đọc.
```

Không tự động show lại quảng cáo ngay.

Người dùng có thể bấm thử lại.

---

# 48. Concurrency

Rewarded manager phải có:

```dart
Completer<RewardedAdResult>? _activeRewardRequest;
```

Hoặc lock tương đương.

Nếu request mới đến khi request cũ đang chạy:

* Không show thêm ad.
* Có thể trả về cùng Future hiện tại nếu cùng luồng.
* Hoặc trả kết quả denied/busy rõ ràng.

Interstitial navigation phải có lock chống double navigation.

App open không được show nếu bất kỳ full-screen manager nào đang hoạt động.

---

# 49. Memory safety

Bảo đảm:

* Mỗi ad instance dispose đúng một lần.
* Sau dispose set về null.
* Không gọi show trên ad đã dispose.
* Không gọi setState sau widget dispose.
* Sau await phải kiểm tra `mounted` hoặc `context.mounted`.
* Không lưu `BuildContext` trong singleton.
* Không reuse `AdWidget` cho ad instance khác.
* Không để callback cũ thay đổi state của ad mới.
* Cancel hoặc bỏ qua delayed callback khi widget đã dispose.
* Không gọi dispose service toàn app từ một màn hình con.

---

# 50. Giữ tương thích code cũ

Nếu có widget cũ:

```text
AdBannerWidget
NativeAdWidget
RewardedInterstitialAdWidget
```

Thực hiện một trong hai cách:

## Cách ưu tiên

* Thay toàn bộ usage bằng widget/service mới.
* Xóa file cũ nếu không còn dùng.

## Cách tương thích

* Giữ wrapper cũ gọi implementation mới.
* Đánh dấu deprecated nếu phù hợp.
* Không giữ hai implementation tải ad riêng biệt.

Không để dead code quảng cáo cũ trong repository.

Không để import unused.

---

# 51. Không thay đổi ngoài phạm vi

Không được:

* Thay đổi API backend.
* Thay đổi base URL.
* Thay đổi URL cũ.
* Thay đổi response model.
* Thay đổi auth.
* Thay đổi guest mode.
* Thay đổi favorite/following permission.
* Thay đổi notes.
* Thay đổi review feature flag.
* Thay đổi localization.
* Thay đổi bottom navigation.
* Thay đổi application ID.
* Thay đổi AdMob App ID.
* Thay đổi Ad Unit ID.
* Thêm subscription.
* Thêm in-app purchase.
* Thêm paywall.
* Thêm backend mới.
* Thêm Remote Config parameter quảng cáo.
* Thay đổi cách server bật/tắt `isAds`.

---

# 52. Static validation

Agent không được build ứng dụng.

Sau khi sửa code:

```bash
dart format lib
```

Nếu có test được sửa:

```bash
dart format lib test
```

Sau đó:

```bash
flutter analyze
```

Có thể chạy:

```bash
dart analyze
```

nếu hữu ích.

Không chạy:

```bash
flutter run
flutter build apk
flutter build appbundle
flutter build ios
gradle assemble
pod install
xcodebuild
```

Không yêu cầu emulator.

Không yêu cầu thiết bị thật.

Không cố sửa native runtime bằng cách build.

---

# 53. Quy tắc xử lý lỗi analyze

Agent phải sửa toàn bộ error phát sinh từ thay đổi mới.

Không được thêm:

```dart
// ignore_for_file
```

để che lỗi.

Không dùng lint suppression trừ khi thật sự có lý do và phải giải thích.

Xóa:

* Import không dùng.
* Biến không dùng.
* Method không dùng.
* Dead code quảng cáo cũ.
* Kiểu nullable sai.
* Callback Future không xử lý nếu lint báo lỗi.

Nếu repository có warning cũ không liên quan:

* Không cần refactor toàn dự án.
* Phải ghi rõ warning nào tồn tại trước hoặc ngoài phạm vi.
* Không được tuyên bố analyze sạch nếu thực tế còn warning/error.

---

# 54. Tiêu chí hoàn thành kiến trúc

Hoàn thành khi:

* Không còn `RewardedAd.load` trong PreviewScreen.
* Không còn `RewardedInterstitialAd.load` trong PreviewScreen.
* Không còn `RewardedAd.load` trong DetailBookScreen.
* Không còn `InterstitialAd.load` trong các screen.
* Không còn `AppOpenAd.load` ngoài ad manager/service.
* Không còn nút X custom trên banner.
* Không còn error text quảng cáo trong UI.
* Không còn reset chapter unlock trong dispose.
* Preview và Detail dùng chung ChapterAdGate.
* Có global full-screen lock.
* Có interstitial action counter.
* Có interstitial cooldown.
* Có app open cooldown.
* Có adaptive banner.
* Có native list helper.
* Không thêm Remote Config key quảng cáo.

---

# 55. Tiêu chí hoàn thành placement

## Home

* Một native sau Top thịnh hành.
* Một adaptive banner cuối trang.

## All Books

* Native xen kẽ.

## Search landing

* Một adaptive banner cuối trang.

## Search result

* Native xen kẽ.

## Favorites

* Native xen kẽ khi có dữ liệu.

## History

* Native xen kẽ khi có dữ liệu.

## Following

* Native xen kẽ khi có dữ liệu.

## Ranking

* Native sau podium hoặc trong danh sách sách.

## Preview

* Tối đa một native.

## Reading

* Chương lẻ có banner cuối chương.
* Chương chẵn có native cuối chương.
* Từ chương 4 dùng rewarded gate.
* Một rewarded mở hai chương.

## Account

* Không thêm quảng cáo.

---

# 56. Tiêu chí chapter unlock

Hoàn thành khi:

```text
Chương 1–3 mở trực tiếp.
Chương 4 yêu cầu rewarded.
Xem hết rewarded mở chương 4 và 5.
Chương 5 không yêu cầu ad lại.
Chương 6 yêu cầu rewarded mới.
Mở khóa được lưu theo bookId.
Đổi sách không dùng unlock của sách trước.
Rời màn hình không reset unlock.
Đóng ad sớm không mở chương.
Ad lỗi sau 3 lần chỉ mở tạm chương hiện tại.
Không mở khóa chương kế tiếp khi ad lỗi.
Ads off thì mọi chương mở trực tiếp.
```

---

# 57. Kiểm tra tĩnh cấu hình native

Agent phải đọc và báo cáo:

* Android AdMob App ID trong `AndroidManifest.xml`.
* iOS AdMob App ID trong `Info.plist`.
* Native factory `listTile` có được đăng ký ở Android không.
* Native factory `listTile` có được đăng ký ở iOS không.
* App open Ad Unit ID còn tồn tại trong service.
* Debug dùng test ID.
* Release dùng production ID.

Không sửa App ID nếu không có lỗi rõ ràng.

Không tạo App ID mới.

Không tạo native factory mới nếu không cần.

Do không build, agent chỉ xác nhận dựa trên static inspection.

---

# 58. Báo cáo cuối của agent

Agent phải trả về:

1. Danh sách file đã tạo.
2. Danh sách file đã sửa.
3. Danh sách file quảng cáo cũ đã xóa.
4. Kiến trúc AdMob mới.
5. Các placement đã triển khai.
6. Quy tắc interstitial.
7. Quy tắc app open.
8. Quy tắc chapter unlock.
9. Cách `isAds` bật/tắt toàn bộ quảng cáo.
10. Xác nhận không thêm Remote Config key.
11. Xác nhận không thay đổi URL cũ.
12. Xác nhận không thay đổi base URL.
13. Xác nhận không thay đổi Ad Unit ID.
14. Kết quả `dart format`.
15. Kết quả `flutter analyze`.
16. Warning/error còn lại nếu có.
17. Xác nhận không chạy build.
18. Danh sách kiểm tra thủ công cần thực hiện trên thiết bị thật.

---

# 59. Danh sách QA thủ công cần báo cáo

Agent không chạy app nhưng phải đưa checklist:

```text
1. isAds = off thì không có bất kỳ quảng cáo nào.
2. isAds được bật thì tất cả loại quảng cáo hoạt động theo mặc định.
3. Cold start không hiện app open.
4. Session 1–2 không hiện app open.
5. Session 3 trở đi có thể hiện app open.
6. Resume dưới 90 giây không hiện app open.
7. Resume trên 90 giây có thể hiện app open.
8. App open không xuất hiện liên tiếp.
9. Interstitial chỉ xuất hiện sau 3 lượt mở sách.
10. Interstitial không xuất hiện liên tiếp trong dưới 3 phút.
11. Interstitial lỗi vẫn mở PreviewScreen.
12. Double tap không mở hai PreviewScreen.
13. Home có một native và một banner.
14. Search landing có một banner.
15. Search result chèn native đúng index.
16. Search pagination không bị ảnh hưởng.
17. Favorites rỗng không hiện quảng cáo.
18. Favorites grid không sai index.
19. Favorites list không sai index.
20. History rỗng không hiện quảng cáo.
21. Following rỗng không hiện quảng cáo.
22. Ranking podium không bị chèn quảng cáo giữa top 3.
23. Preview chỉ có một native.
24. Chương 1–3 đọc trực tiếp.
25. Chương 4 yêu cầu rewarded.
26. Rewarded thành công mở chương 4 và 5.
27. Chương 6 yêu cầu rewarded mới.
28. Đóng rewarded sớm không mở chương.
29. Rewarded lỗi sau retry cho đọc tạm chương hiện tại.
30. Unlock của sách A không áp dụng cho sách B.
31. Rời màn đọc rồi quay lại không mất unlock.
32. Chương lẻ có banner cuối chương.
33. Chương chẵn có native cuối chương.
34. Banner lỗi thì collapse.
35. Native lỗi thì collapse.
36. Không có error text quảng cáo trong UI.
37. Không có nút đóng custom trên banner.
38. Không có quảng cáo trong login/signup/password.
39. Debug dùng test ID.
40. Release dùng production ID.
41. URL server vẫn giữ nguyên.
42. Base URL vẫn giữ nguyên.
43. Không có Remote Config key quảng cáo mới.
44. iOS giữ nguyên trạng thái quảng cáo theo logic cũ.
```

---

# 60. Chỉ dẫn thực thi cuối cùng

Hãy trực tiếp sửa code trong repository.

Không chỉ phân tích hoặc viết kế hoạch.

Không chia thành nhiều phase.

Không dừng giữa chừng để hỏi xác nhận.

Không tạo nhiều PR.

Không thêm tham số Remote Config quảng cáo.

Không thay đổi URL cũ.

Không thay đổi base URL.

Không thay đổi cơ chế server bật/tắt `isAds`.

Không thay đổi Ad Unit ID.

Mặc định, khi `isAds` cho phép, toàn bộ quảng cáo được bật và dùng các giá trị cố định trong code.

Sau khi hoàn tất:

```bash
dart format lib
flutter analyze
```

Sửa toàn bộ lỗi tĩnh phát sinh từ thay đổi mới.

Không build ứng dụng.

Không chạy ứng dụng.

Kết thúc bằng báo cáo đầy đủ theo yêu cầu trong spec.
