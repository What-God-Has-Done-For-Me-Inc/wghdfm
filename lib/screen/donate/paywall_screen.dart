import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wghdfm_java/services/in_app_purchase.dart';

import '../../common/common_snack.dart';
import '../../modules/auth_module/model/login_model.dart';
import '../../services/sesssion.dart';

class PaywallScreen extends StatefulWidget {
  final Offering? offering;

  const PaywallScreen({Key? key, this.offering}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "My Christian Social Networks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Get.height * 0.02),
            const Text(
              "This is a social network where people can be like minded in glorifying the Lord. It's your monthly contribution that keeps us moving.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Get.height * 0.05),
            ListView.builder(
              itemCount: widget.offering!.availablePackages.length,
              itemBuilder: (BuildContext context, int index) {
                var myProductList = widget.offering!.availablePackages;
                // print(myProductList[index].toJson());
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: _selectedPackage != myProductList[index]
                        ? Colors.white
                        : getBadgeColor(badge: myProductList[index].identifier)
                            .withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                        width: 1,
                        color: _selectedPackage != myProductList[index]
                            ? Colors.white
                            : getBadgeColor(
                                    badge: myProductList[index].identifier)
                                .withOpacity(0.5)),
                  ),
                  child: ListTile(
                      onTap: () {
                        print(myProductList[index].toJson());
                        setState(() {
                          _selectedPackage = myProductList[index];
                        });
                      },
                      title: Text(
                        myProductList[index].identifier,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: _buildPackageDescription(myProductList[index]),
                      trailing: Image.asset(
                        getBadgeImage(badge: myProductList[index].identifier),
                        height: 30,
                        width: 30,
                      )),
                );
              },
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
            ),
            GestureDetector(
              onTap: () async {
                if (_selectedPackage != null) {
                  try {
                    CustomerInfo customerInfo =
                        await Purchases.purchasePackage(_selectedPackage!);

                    // print(customerInfo.toJson());
                    LoginModel userDetails =
                        await SessionManagement.getUserDetails();
                    var userId = userDetails.id;
                    RevenueCateServices().subscriptionSuccess(
                        user_id: userId!,
                        product_id: _selectedPackage!.storeProduct.identifier,
                        payment_id: customerInfo.originalAppUserId,
                        plan: _selectedPackage!.storeProduct.defaultOption!
                            .billingPeriod!.unit.name,
                        duration: _selectedPackage!
                            .storeProduct.defaultOption!.billingPeriod!.value
                            .toString(),
                        price: _selectedPackage!.storeProduct.priceString,
                        badge: _selectedPackage!.identifier
                            .split(" ")
                            .first
                            .toString(),
                        currency: _selectedPackage!.storeProduct.currencyCode);
                  } catch (e) {
                    print(e);
                  }

                  setState(() {});
                } else {
                  snack(
                    title: 'Level Not Selected!',
                    msg: 'Please select any level to continue',
                    icon: Icons.close,
                    iconColor: Colors.red,
                  );
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: _selectedPackage == null
                        ? Colors.grey.shade100
                        : Colors.blue),
                child: Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _selectedPackage == null
                          ? Colors.grey
                          : Colors.white),
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            GestureDetector(
              onTap: () {
                RevenueCateServices().restorePurchases();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    MingCute.refresh_2_line,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: Get.width * 0.01),
                  const Text(
                    "Restore Purchase",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.03),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              GestureDetector(
                onTap: () {
                  launchUrlString(
                      "https://whatgodhasdoneforme.com/privacy-policy");
                },
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrlString("https://whatgodhasdoneforme.com/eula");
                },
                child: const Text(
                  "Terms of Use (EULA)",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(height: Get.height * 0.05),
          ],
        ),
      ),
    );
  }

  _buildPackageDescription(Package package) {
    String packageType = '';
    if (package.packageType == PackageType.custom) packageType = 'Per Month';
    if (package.packageType == PackageType.weekly) packageType = 'Weekly';
    if (package.packageType == PackageType.monthly) packageType = 'Monthly';
    if (package.packageType == PackageType.threeMonth) packageType = '3 Months';
    if (package.packageType == PackageType.sixMonth) packageType = '6 Months';
    if (package.packageType == PackageType.annual) packageType = 'Annual';

    String packageName =
        package.storeProduct.priceString + ' ' + packageType + ' ';

    return Text(
      packageName,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color getBadgeColor({required String badge}) {
    switch (badge) {
      case "Basic Level Partner":
        return Colors.grey.shade800;

      case "Bronze Level Partner":
        return Color(0xffCD7F32);

      case "Silver Level Partner":
        return Color(0xffC0C0C0);
      case "Gold Level Partner":
        return Color(0xffFFD700);
      case "Platinum Level Partner":
        return Color(0xffE5E4E2);
      case "Diamond Level Partner":
        return Color(0xffb9f2ff);

      default:
        return Colors.black;
    }
  }

  // badge image url
  String getBadgeImage({required String badge}) {
    switch (badge) {
      case "Basic Level Partner":
        return "assets/1.png";
      case "Bronze Level Partner":
        return "assets/2.png";
      case "Silver Level Partner":
        return "assets/3.png";
      case "Gold Level Partner":
        return "assets/4.png";
      case "Platinum Level Partner":
        return "assets/5.png";
      case "Diamond Level Partner":
        return "assets/6.png";
      default:
        return "assets/1.png";
    }
  }
}
