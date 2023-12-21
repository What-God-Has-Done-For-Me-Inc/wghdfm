import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<VoidCallback> postOptionOnClicks() {
  var callBacks = <VoidCallback>[
    () {
      debugPrint("Status");
    },
    () {
      debugPrint("Photo");
    },
    () {
      debugPrint("Video");
    },
  ];

  return callBacks;
}

Widget loadMoreItem({required VoidCallback? onLoad}) {
  return Container(
    color: Theme.of(Get.context!).colorScheme.secondary,
    margin: const EdgeInsets.all(5),
    child: ElevatedButton(
      child: const Text("Load More"),
      onPressed: () {
        onLoad!();
      },
    ),
  );
}
