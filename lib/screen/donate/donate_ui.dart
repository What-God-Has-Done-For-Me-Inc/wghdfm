import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/common/background_widget.dart';
import 'package:wghdfm_java/common/common_snack.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/screen/donate/donate_controller.dart';
import 'package:wghdfm_java/screen/donate/paypal_payment_.dart';
import 'package:wghdfm_java/screen/donate/paypal_sdk_screen.dart';
import 'package:wghdfm_java/screen/donate/paypal_web_recurring_screen.dart';
import 'package:wghdfm_java/services/in_app_purchase.dart';
import 'package:wghdfm_java/utils/app_colors.dart';
import 'package:wghdfm_java/utils/button.dart';
import 'package:wghdfm_java/utils/scale_ui_utils.dart';

class DonateUI extends StatelessWidget {
  /*DonateUI({Key key}) : super(key: key);*/

  RxInt selectedRecurring = 10.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonateController>(
      init: DonateController(),
      global: false,
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black45.withOpacity(0.3),
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            title: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: Get.width),
              margin: const EdgeInsets.all(10),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "What ",
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontSize: 16.0.sf),
                    ),
                    Text(
                      "God ",
                      style: GoogleFonts.montserrat(
                          color: Colors.red, fontSize: 16.0.sf),
                    ),
                    Text(
                      "Has ",
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontSize: 16.0.sf),
                    ),
                    Text(
                      "Done ",
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontSize: 16.0.sf),
                    ),
                    Text(
                      "For ",
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontSize: 16.0.sf),
                    ),
                    Text(
                      "Me",
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontSize: 16.0.sf),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: backGroundWidget(
            widget: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: RichText(
                        text: TextSpan(
                            text: c.whyNWhat,
                            style: GoogleFonts.montserrat(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                            children: [
                              const TextSpan(text: "\n\n"),
                              TextSpan(
                                text: c.ourMission,
                                style: GoogleFonts.montserrat(
                                    color: AppColors.blackColor,
                                    fontSize: 15.0.sf),
                              ),
                            ]),
                        textAlign: TextAlign.justify,
                      )),

                  Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: RichText(
                        text: TextSpan(
                            text: "Our Objective",
                            style: GoogleFonts.montserrat(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                            children: [
                              const TextSpan(text: "\n\n"),
                              TextSpan(
                                text: c.ourObjective,
                                style: GoogleFonts.montserrat(
                                    color: AppColors.blackColor,
                                    fontSize: 15.0.sf),
                              ),
                            ]),
                        textAlign: TextAlign.justify,
                      )),
                  Text(
                    "Please Partner With Us",
                    style: GoogleFonts.openSans(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),

                  // Container(
                  //   width: Get.width,
                  //   height: 50,
                  //   padding: const EdgeInsets.all(5),
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       Get.to(() => PaypalWebRecurringScreen(
                  //             price: selectedRecurring.value,
                  //           ));
                  //     },
                  //     child: Text(
                  //       "Continue".toUpperCase(),
                  //       style: GoogleFonts.openSans(
                  //           color: Colors.white, fontSize: 16.0.sf),
                  //     ),
                  //   ),
                  // ),

                   customButton(
                       title: 'DONATE',
                       onTap: () {
                         RevenueCateServices().configureSDK();
                        // Get.to(const PaypalPayment());
                       }),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            width: Get.width,
            color: Colors.transparent,
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            child: Text(
              "whatgodhasdoneforme@yahoo.com",
              style:
                  GoogleFonts.montserrat(color: AppColors.black, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  void onCLickBottomSheet(DonateController c) {
    customModalBottomSheet(
      widget: ListView(shrinkWrap: false, children: [
        Container(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor,
              borderRadius: BorderRadius.circular(10),
              /*border: Border(
                    top: BorderSide(
                  color: Theme.of(Get.context).accentColor,
                  width: 1,
                  ),
                ),*/
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: commonTextField(
                    readOnly: false,
                    hint: 'Enter Amount in \$',
                    isLabelFloating: true,
                    inputType: TextInputType.number,
                    controller: c.donationAmtTEC,
                    borderColor: Theme.of(Get.context!).colorScheme.surface,
                    baseColor: Theme.of(Get.context!).colorScheme.surface,
                    isLastField: true,
                    obscureText: false,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  height: 40,
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (c.donationAmtTEC.text.trim().isNotEmpty) {
                        Get.back();

                        ///Romil Codes.
                        // Get.to(()=> PayPalRecurringScreen());
                        // goToProcessTransaction(
                        //     price: c.donationAmtTEC.text.trim());
                      } else {
                        snack(
                            icon: Icons.report_problem,
                            iconColor: Colors.yellow,
                            msg:
                                "Please first enter the intended amount you want to donate",
                            title: "Alert!");
                      }
                    },
                    child: Text(
                      "Contribute".toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                /*SizedBox(
                  height: 3,
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  height: 40,
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (c.donationAmtTEC.text.trim().isNotEmpty) {
                        Get.back();
                        goToProcessTransaction(
                            price: c.donationAmtTEC.text.trim());
                      } else {
                        snack(
                            msg:
                                "Please first enter the intended amount you want to donate",
                            title: "Alert!");
                      }
                    },
                    child: Text(
                      "Monthly Payment",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),*/
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
