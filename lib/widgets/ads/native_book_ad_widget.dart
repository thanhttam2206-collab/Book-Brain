import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/service/service_config/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeBookAdWidget extends StatefulWidget {
  const NativeBookAdWidget({required this.placement, super.key});

  final AdPlacement placement;

  @override
  State<NativeBookAdWidget> createState() => _NativeBookAdWidgetState();
}

class _NativeBookAdWidgetState extends State<NativeBookAdWidget> {
  static const double _compactHeight = 100;
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdMobService.instance.adsEnabled) _load();
  }

  Future<void> _load() async {
    final ad = NativeAd(
      adUnitId: AdMobService.instance.getAdUnitId('native'),
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || loadedAd != _ad) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
          if (!mounted || failedAd != _ad) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!AdMobService.instance.adsEnabled || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: _compactHeight,
      width: double.infinity,
      child: AdWidget(key: ObjectKey(ad), ad: ad),
    );
  }
}
