import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wghdfm_java/modules/ads_module/ads_helper.dart';

class AdsController {
  static Future<InitializationStatus> initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['4ba2a94a7a44a47fdbbc1a8e93013f70']));
    return MobileAds.instance.initialize();
  }

  BannerAd? bannerAd;
  loadBannerAds() async {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("::: BANNER ADS > LOADED >> ${ad.adUnitId}");
          bannerAd = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }
}
