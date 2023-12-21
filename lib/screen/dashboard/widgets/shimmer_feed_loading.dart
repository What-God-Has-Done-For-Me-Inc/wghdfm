import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/shimmer_utils.dart';

Widget shimmerFeedLoading() {
  return ListView(
    physics: const NeverScrollableScrollPhysics(),
    children: [
      Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  shimmerMeUp(
                    const CircleAvatar(
                      child: SizedBox(width: 70, height: 70),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: shimmerMeUp(Container(
                      height: 20,
                      color: Colors.grey,
                    )),
                  ),
                ],
              ),
            ),
            shimmerMeUp(
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: Get.width,
                    color: Colors.grey,
                  )),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.favorite_border)),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 20,
                      child: Image.asset(
                        "assets/icon/like_img.png",
                        color: Theme.of(Get.context!).iconTheme.color,
                      ),
                    )),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.add_box)),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.share)),
                  ),
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(
                      const Icon(
                        Icons.report_problem,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: shimmerMeUp(Container(
                margin: const EdgeInsets.all(10),
                width: 100,
                height: 20,
                color: Colors.grey,
              )),
            ),
          ],
        ),
      ),
      Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  shimmerMeUp(
                    const CircleAvatar(
                      child: SizedBox(width: 70, height: 70),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: shimmerMeUp(Container(
                      height: 20,
                      color: Colors.grey,
                    )),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: shimmerMeUp(
                      const Icon(
                        Icons.more_horiz,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shimmerMeUp(
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: Get.width,
                    color: Colors.grey,
                  )),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 20,
                      child: Image.asset(
                        "assets/icon/like_img.png",
                        color: Theme.of(Get.context!).iconTheme.color,
                      ),
                    )),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.messenger_outline)),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.share)),
                  ),
                  const Expanded(
                    flex: 4,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 1,
                    child: shimmerMeUp(const Icon(Icons.favorite_border)),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: shimmerMeUp(Container(
                margin: const EdgeInsets.all(10),
                width: 100,
                height: 20,
                color: Colors.grey,
              )),
            ),
          ],
        ),
      ),
    ],
  );
}
