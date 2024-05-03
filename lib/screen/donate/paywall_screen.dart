import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wghdfm_java/services/in_app_purchase.dart';

import '../../modules/auth_module/model/login_model.dart';
import '../../services/sesssion.dart';

class PaywallScreen extends StatefulWidget {
  final Offering? offering;

  const PaywallScreen({Key? key, this.offering}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String badge = '';
  String price = '';
  String currency = '';
  String plan = '';
  int duration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PaywallView(
            offering: widget.offering,
            displayCloseButton: true,
            onPurchaseStarted: (Package rcPackage) {
              //print(rcPackage.toJson());
              print('badge: ${rcPackage.identifier}');
              // print('Currency: ${rcPackage.storeProduct.currencyCode}');
              // print(
              //     'month: ${rcPackage.storeProduct.defaultOption!.billingPeriod!.value}');
              // print(
              //     'type: ${rcPackage.storeProduct.defaultOption!.billingPeriod!.unit.name}');
              setState(() {
                badge = rcPackage.identifier.split(" ").first.toString();
                price = rcPackage.storeProduct.priceString;
                currency = rcPackage.storeProduct.currencyCode;
                plan = rcPackage
                    .storeProduct.defaultOption!.billingPeriod!.unit.name;
                duration =
                    rcPackage.storeProduct.defaultOption!.billingPeriod!.value;
              });
            },
            onPurchaseCompleted: (CustomerInfo customerInfo,
                StoreTransaction storeTransaction) async {
              // print('Purchase completed for customerInfo:\n $customerInfo\n '
              //     'and storeTransaction:\n $storeTransaction');
              print("activeSubscriptions ${customerInfo.activeSubscriptions}");
              print("payment id ${customerInfo.originalAppUserId}");
              print("purchaseDate ${storeTransaction.purchaseDate}");
              print("productIdentifier ${storeTransaction.productIdentifier}");
              LoginModel userDetails = await SessionManagement.getUserDetails();
              var userId = userDetails.id;
              RevenueCateServices().subscriptionSuccess(
                  user_id: userId!,
                  product_id: storeTransaction.productIdentifier,
                  payment_id: customerInfo.originalAppUserId,
                  plan: plan,
                  duration: duration.toString(),
                  price: price,
                  badge: badge,
                  currency: currency);
            },
            onPurchaseError: (PurchasesError error) {
              print('Purchase error: $error');
            },
            onRestoreCompleted: (CustomerInfo customerInfo) {
              print('Restore completed for customerInfo:\n $customerInfo');
            },
            onRestoreError: (PurchasesError error) {
              print('Restore error: $error');
            },
            onDismiss: () {
              print('Paywall asked to dismiss');
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
