import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget backGroundWidget({required Widget widget}) {
  return Stack(
    children: [
      Container(
        color: Colors.white,
        width: Get.width,
        height: Get.height,
        child: Image.asset(
          'assets/drawable/background.jpg',
          fit: BoxFit.cover,
          width: Get.width,
          height: Get.height,
        ),
      ),
      Container(
        color: Colors.white.withOpacity(0.3),
        constraints: BoxConstraints(
          maxWidth: Get.width,
          maxHeight: Get.height,
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: widget,
      ),
    ],
  );
}
