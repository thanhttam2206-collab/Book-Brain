import 'package:book_brain/service/ads/ad_placement.dart';
import 'package:book_brain/service/service_config/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdaptiveBannerAdWidget extends StatefulWidget {
  const AdaptiveBannerAdWidget({required this.placement, super.key});

  final AdPlacement placement;

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _ad;
  Widget? _adWidget;
  bool _loadScheduled = false;

  void _scheduleLoad(double availableWidth) {
    if (_loadScheduled ||
        _ad != null ||
        !AdMobService.instance.adsEnabled ||
        availableWidth < AdSize.banner.width) {
      return;
    }
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdMobService.instance.getAdUnitId('banner'),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || loadedAd != _ad) return;
          final loadedBanner = loadedAd as BannerAd;
          setState(() {
            // Keep one AdWidget instance for the lifetime of this BannerAd.
            // Recreating it can ask iOS to mount the same UIKit view twice.
            _adWidget = AdWidget(ad: loadedBanner);
          });
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
          if (!mounted || failedAd != _ad) return;
          setState(() {
            _ad = null;
            _adWidget = null;
            _loadScheduled = false;
          });
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdMobService.instance.adsEnabled) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        _scheduleLoad(availableWidth);
        final adWidget = _adWidget;
        if (adWidget == null) return const SizedBox.shrink();
        return SizedBox(
          width: double.infinity,
          height: AdSize.banner.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: AdSize.banner.width.toDouble(),
              height: AdSize.banner.height.toDouble(),
              child: adWidget,
            ),
          ),
        );
      },
    );
  }
}
