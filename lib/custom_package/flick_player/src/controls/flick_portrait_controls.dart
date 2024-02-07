import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flick_video_player.dart';
import '../widgets/video_quality_widget.dart';

/// Default portrait controls.
class FlickPortraitControls extends StatelessWidget {
  const FlickPortraitControls({
    Key? key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarSettings,
  }) : super(key: key);

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;

  @override
  Widget build(BuildContext context) {
    FlickDisplayManager displayManager =
        Provider.of<FlickDisplayManager>(context);
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickVideoBuffer(
                  child: FlickAutoHideChild(
                    showIfVideoNotInitialized: false,
                    child: FlickPlayToggle(
                      size: 30,
                      color: Colors.black,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlickVideoProgressBar(
                    flickProgressBarSettings: progressBarSettings),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlickPlayToggle(
                      size: iconSize,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    FlickSoundToggle(
                      size: iconSize,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    Row(
                      children: <Widget>[
                        FlickCurrentPosition(
                          fontSize: fontSize,
                        ),
                        FlickAutoHideChild(
                          child: Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                        ),
                        FlickTotalDuration(
                          fontSize: fontSize,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    FlickSubtitleToggle(
                      size: iconSize,
                    ),
                    if (displayManager.showQualityButton) ...[
                      const VideoQualityWidget(),
                      SizedBox(width: iconSize / 4),
                    ],
                    FlickFullScreenToggle(size: iconSize),
                    SizedBox(width: iconSize / 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
