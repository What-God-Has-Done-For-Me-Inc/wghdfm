import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerMeUp(Widget widget) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    enabled: true,
    child: widget,
  );
}
