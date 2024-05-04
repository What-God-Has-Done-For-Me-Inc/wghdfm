import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:dio/dio.dart' as dio;

import '../common/common_snack.dart';
import '../networking/api_service_class.dart';
import '../screen/donate/paywall_screen.dart';
import '../utils/app_methods.dart';
import '../utils/endpoints.dart';

class RevenueCateServices {
  Future<void> configureSDK() async {
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
      // final result = await RevenueCatUI.presentPaywallIfNeeded("Pro");
      // log("Paywall Result: $result");
      try {
        Offerings? offerings = await Purchases.getOfferings();
        if (offerings.current == null ||
            offerings.current!.availablePackages.isEmpty) {
          // MyDialogs.error(msg: "No offerings available");
        }
        Get.to(PaywallScreen(offering: offerings.current));
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  void restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      print("Restore Purchase");
      print(customerInfo.toJson());
      snack(
        title: 'Success',
        msg: 'Restore Purchases Success',
        icon: Icons.check,
        iconColor: Colors.green,
        seconds: 1,
      );
    } catch (e) {
      snack(
        title: 'Failed',
        msg: 'Restore purchases failed',
        icon: Icons.close,
        iconColor: Colors.red,
      );
    }
  }

  subscriptionSuccess(
      {required String user_id,
      required String product_id,
      required String payment_id,
      required String plan,
      required String duration,
      required String price,
      required String currency,
      required String badge}) async {
    await APIService().callAPI(
        params: {},
        formDatas: dio.FormData.fromMap({
          "user_id": user_id,
          "product_id": product_id,
          "payment_id": payment_id,
          "plan": plan,
          "duration": duration,
          "price": price,
          "currency": currency,
          "badge": badge,
        }),
        headers: {},
        serviceUrl: EndPoints.baseUrl + EndPoints.donate,
        method: APIService.postMethod,
        success: (dio.Response response) {
          if (response.data.contains('success')) {
            snack(
              title: 'Subscription successful!',
              msg: 'You are subscribed user now...',
              icon: Icons.check,
              iconColor: Colors.green,
              seconds: 1,
            );
            Get.back();
          } else {
            snack(
              title: 'Subscription failed!',
              msg: '${response.data['text']}',
              icon: Icons.close,
              iconColor: Colors.red,
            );
            Get.back();
          }
        },
        error: (dio.Response response) {
          final decoded = jsonDecode(response.data);
          AppMethods.showLog(">>>> RESPONSE SUCCESS >> ${decoded['status']}");
          AppMethods.showLog(">>>> RESPONSE ERROR >> ${response}");

          ///Display snackbar here..
        },
        showProcess: true);
  }
}
