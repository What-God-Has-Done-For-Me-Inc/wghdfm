import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'app_colors.dart';

class YoutubeVideoScereen extends StatefulWidget {
  String? videoLink;
  String? videoId;
  YoutubeVideoScereen({Key? key, this.videoLink, this.videoId}) : super(key: key);

  @override
  _YoutubeVideoScereenState createState() => _YoutubeVideoScereenState();
}

class _YoutubeVideoScereenState extends State<YoutubeVideoScereen> {
  YoutubePlayerController? youtubePlayerController;
  String? get getVideoId {
    return widget.videoLink?.contains("youtube.com/watch?v") == true
        ? widget.videoLink?.split("=").last
        : widget.videoLink?.contains("youtu.be") == true
            ? widget.videoLink?.split("/").last
            : "";
  }

  @override
  void initState() {
    youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId ?? getVideoId ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(" YOUTUBE VIDEO Player running with this link.. >${youtubePlayerController?.initialVideoId}");
    return Center(
      child: YoutubePlayer(
        controller: youtubePlayerController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.grey,
      ),
    );
  }
}
