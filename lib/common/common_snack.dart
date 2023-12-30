import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void snack({
  required String title,
  required String msg,
  IconData icon = Icons.check,
  Color iconColor = Colors.green,
  double iconSize = 30,
  Color bgColor = Colors.black,
  Color textColor = Colors.white,
  int seconds = 2,
  String? actionLabel,
  SnackPosition position = SnackPosition.TOP,
  VoidCallback? onActionTap,
}) {
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }
  Get.snackbar(
    title,
    msg,
    shouldIconPulse: true,
    icon: Icon(
      icon,
      color: iconColor,
      size: iconSize,
    ),
    backgroundColor: bgColor,
    colorText: textColor,
    duration: Duration(
      seconds: seconds,
    ),
    snackPosition: position,
    dismissDirection: DismissDirection.none,
    mainButton: actionLabel != null
        ? TextButton(
            child: Text(
              actionLabel,
              style: TextStyle(
                  color: (textColor != null)
                      ? textColor
                      : Theme.of(Get.context!).primaryColor),
            ),
            onPressed: () {
              onActionTap!();
            })
        : null,
  );
}

void showDailogBox({
  required BuildContext context,
  required String title,
  required String subTitle,
}) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          insetPadding: const EdgeInsets.all(12),
          actionsPadding: const EdgeInsets.only(right: 14, bottom: 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: Get.height * 0.01),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      //color: blackColor,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: Get.height * 0.01),
                Text(
                  subTitle,
                  style: const TextStyle(
                      fontSize: 14,
                      // color: blackColor.withOpacity(.56),
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: Get.height * 0.02),
                Text.rich(TextSpan(
                    text: 'Cancel',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff080808).withOpacity(.56)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.back())),
                SizedBox(height: Get.height * 0.01),
              ],
            ),
          ),
        );
      });
}
