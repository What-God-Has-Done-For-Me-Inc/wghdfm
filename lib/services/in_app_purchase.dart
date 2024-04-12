import 'dart:developer';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
/*
class RevenueCateServices {
  static Future<void> configureSDK() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration("goog_SiIamYVANvMlEctZpSTqrZClEvm");
    } else {
      configuration =
          PurchasesConfiguration("appl_JzofMSwIQcysmuGXvbWsTWKmVWc");
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      final result = await RevenueCatUI.presentPaywallIfNeeded("Pro");
      log("Paywall Result: $result");
    }
  }
}
*/