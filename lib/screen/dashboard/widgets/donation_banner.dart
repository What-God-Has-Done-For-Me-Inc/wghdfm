import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/endpoints.dart';

import '../../donate/donate_ui.dart';

class DonateBanner extends StatelessWidget {
  const DonateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(DonateUI()),
      child: Image.network("${EndPoints.webUrl}images/ad_1_donate.jpg"),
    );
  }
}
