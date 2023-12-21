import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget backGroundWidget({required Widget widget}) {
  return Stack(
    children: [
      Container(
        color: Colors.black,
        width: Get.width,
        height: Get.height,
        child: Image.asset(
          // 'assets/drawable/splash_bg.jpeg',
          'assets/drawable/newSplashBg.jpg',
          fit: BoxFit.cover,
          width: Get.width,
          height: Get.height,
        ),

        /*CachedNetworkImage(
          alignment: Alignment.center,
          fit: BoxFit.fill,
          imageUrl:
              'https://images.pexels.com/photos/5206040/pexels-photo-5206040.jpeg?cs=srgb&dl=pexels-tima-miroshnichenko-5206040.jpg&fm=jpg',
          placeholder: (context, url) => Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 70,
              height: 70,
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),*/
        /*Image.network(
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),*/
      ),
      Container(
        color: Colors.black.withOpacity(0.5),
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
