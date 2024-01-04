import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wghdfm_java/utils/app_colors.dart';

Widget customButton(
    {required String title, required Function() onTap, Color? buttonColor}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: Get.width,
      height: Get.height * 0.06,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: buttonColor != null ? buttonColor : AppColors.primery,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.all(5),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
