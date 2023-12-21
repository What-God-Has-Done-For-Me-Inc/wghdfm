import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wghdfm_java/modules/ads_module/ads_helper.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({Key? key}) : super(key: key);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  BannerAd? bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    if (!kDebugMode) {
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.largeBanner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print("::: BANNER ADS > LOADED >> ${ad.adUnitId}");
            setState(() {
              bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${ad.adUnitId} ------${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        color: Colors.red,
      );
    }
    return bannerAd != null
        ? Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              // width: bannerAd!.size.width.toDouble(),
              // height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            ),
          )
        : SizedBox();
  }
}
