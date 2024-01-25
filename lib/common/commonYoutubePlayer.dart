import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CommonYTPlayer extends StatefulWidget {
  final String videoId;

  const CommonYTPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  State<CommonYTPlayer> createState() => _CommonYTPlayerState();
}

class _CommonYTPlayerState extends State<CommonYTPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    var videoUrl = widget.videoId.contains("youtube.com/live/")
        ? widget.videoId.split("/").last.split('?').first
        : YoutubePlayerController.convertUrlToId(widget.videoId);
    print("Youtube Link is " + widget.videoId);
    print(videoUrl);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoUrl.toString(),
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: false,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        return YoutubePlayerScaffold(
          controller: _controller,
          autoFullScreen: false,
          enableFullScreenOnVerticalDrag: false,
          builder: (context, player) {
            return SizedBox(width: Get.width, child: player);
          },
        );
      });
    });
  }
}
