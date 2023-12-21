import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      ///Test PUB ID.
      // return 'ca-app-pub-3940256099942544/6300978111';

      ///Live PUB ID.
      return 'ca-app-pub-9836237192209085/5348093584';
    } else if (Platform.isIOS) {
      ///Test PUB ID>
      // return 'ca-app-pub-3940256099942544/2934735716';

      ///Live PUB ID.
      return 'ca-app-pub-9836237192209085/6017524453';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  // static String get industrialAdUnitId {
  //   if (Platform.isAndroid) {
  //     // return 'ca-app-pub-3940256099942544/6300978111';
  //     return 'ca-app-pub-3878618045060138/4564908224';
  //   } else if (Platform.isIOS) {
  //     return 'ca-app-pub-3940256099942544/2934735716';
  //
  //     ///OLD UNIT ID >>
  //     // return 'ca-app-pub-3878618045060138/7328509223';
  //   } else {
  //     throw new UnsupportedError('Unsupported platform');
  //   }
  // }
}
