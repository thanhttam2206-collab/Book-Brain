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
  bool _loaded = false;
  int? _requestedWidth;

  Future<void> _load(int width) async {
    if (!AdMobService.instance.adsEnabled ||
        width <= 0 ||
        width == _requestedWidth) {
      return;
    }
    _requestedWidth = width;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null || !AdMobService.instance.adsEnabled) return;
    _ad?.dispose();
    final ad = BannerAd(
      adUnitId: AdMobService.instance.getAdUnitId('banner'),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
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
    );
    setState(() {
      _ad = ad;
      _loaded = false;
    });
    await ad.load();
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
        final width =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth.floor()
                : MediaQuery.sizeOf(context).width.floor();
        if (width > 0 && width != _requestedWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
        }
        final ad = _ad;
        if (!_loaded || ad == null) return const SizedBox.shrink();
        return SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(key: ObjectKey(ad), ad: ad),
        );
      },
    );
  }
}
