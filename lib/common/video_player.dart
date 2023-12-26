import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CommonVideoPlayer extends StatefulWidget {
  final String videoLink;
  final bool? isFile;

  const CommonVideoPlayer({Key? key, required this.videoLink, this.isFile})
      : super(key: key);

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayer();
}

class _CommonVideoPlayer extends State<CommonVideoPlayer> {
   late FlickManager flickManager;
   late VideoPlayerController _videoPlayerController;

  int? bufferDelay;

  RxBool thumbnail = true.obs;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  Future<void> initializePlayer() async {
    log("==== LINK OF PLAYER ${widget.videoLink}");
    _videoPlayerController =  VideoPlayerController.networkUrl(
      Uri.parse(widget.videoLink),
    );
    _videoPlayerController.initialize();
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isBuffering) {
        // Video is buffering
        setState(() {
          thumbnail.value = true;
          print('Video is Buffring');
        });
      } else {
        // Video is not buffering
        setState(() {
          thumbnail.value = false;
          print('Video Not Buffring');
        });
      }

    });

    if (widget.isFile == true) {
      flickManager = FlickManager(
          videoPlayerController:
              VideoPlayerController.file(File(widget.videoLink)),
          autoInitialize: true,
          onVideoEnd: () {
            // thumbnail.value = true;
          });
    } else {
      flickManager = FlickManager(
          videoPlayerController:_videoPlayerController,
          autoInitialize: true,
          autoPlay: true,
          onVideoEnd: () {
            thumbnail.value = true;
          });
    }


  }

  // void _createChewieController() {
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController,
  //     // aspectRatio: _videoPlayerController.value.aspectRatio,
  //     autoPlay: true,
  //     looping: false,
  //     autoInitialize: true,
  //     progressIndicatorDelay:
  //         bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
  //     hideControlsTimer: const Duration(seconds: 2),
  //   );
  // }

  @override
  void dispose() {
    flickManager.dispose();
     _videoPlayerController.dispose();
    // _chewieController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.isFile == true) {
      return Container(
        child: FlickVideoPlayer(flickManager: flickManager),
      );
    }
    return StreamBuilder(
        stream: thumbnail.stream,
        builder: (context, snapshot) {
          print(thumbnail.value);
          if (thumbnail.value && !_videoPlayerController.value.isInitialized) {
            print(
                '====${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}');
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      '${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Center(child: Icon(Icons.error));
                  },
                ),
                InkWell(
                  onTap: () {
                    thumbnail.value = false;
                    // flickManager.flickControlManager!.autoResume();
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.play_circle, color: Colors.white, size: 50),
                  ),
                ),
              ],
            );
          }
          return FlickVideoPlayer(
            flickManager: flickManager,
            flickVideoWithControls: const FlickVideoWithControls(
              closedCaptionTextStyle: TextStyle(fontSize: 8),
              controls: FlickPortraitControls(),
            ),
            flickVideoWithControlsFullscreen: const FlickVideoWithControls(
              controls: FlickLandscapeControls(),
            ),
            preferredDeviceOrientationFullscreen: const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.landscapeLeft
            ],
            preferredDeviceOrientation: const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.landscapeLeft
            ],
            systemUIOverlayFullscreen: [SystemUiOverlay.bottom],
            systemUIOverlay: [SystemUiOverlay.top],
          );
        });
  }
}
