import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manager/flick_manager.dart';
import 'video_style.dart';

/// A widget to display the video's current selected quality type.
class VideoQualityWidget extends StatelessWidget {
  /// Constructor
  const VideoQualityWidget({
    Key? key,
    this.videoStyle = const VideoStyle(),
  }) : super(key: key);

  /// The model to provide custom style for the video display widget.
  final VideoStyle videoStyle;

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    return InkWell(
      onTap: displayManager.handeleQualityTap,
      child: Container(
        decoration: BoxDecoration(
          color: videoStyle.videoQualityBgColor ?? Colors.grey,
          borderRadius: videoStyle.videoQualityRadius ??
              const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Padding(
          padding: videoStyle.videoQualityPadding ??
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          child: Text(displayManager.m3u8Quality),
        ),
      ),
    );
  }
}
