// import 'package:flick_video_player/flick_video_player.dart';
import 'dart:developer';
import 'dart:io';

// import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';

// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_player/video_player.dart';

// class CommonVideoPlayer extends StatefulWidget {
//   final String videoLink;
//   final bool? isNetwork;
//   const CommonVideoPlayer({Key? key, required this.videoLink, this.isNetwork}) : super(key: key);
//
//   @override
//   State<CommonVideoPlayer> createState() => _CommonVideoPlayerState();
// }
//
// class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
//   RxString? imgLink;
//
//   // VideoPlayerController _controller = VideoPlayerController.network('https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4')
//   //   ..initialize().then((_) {
//   //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressedvar /   });
//
//   // VideoPlayerController videoPlayerController = VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4");
//   // ChewieController chewieController = ChewieController(videoPlayerController: VideoPlayerController.network("https://wghdfm.s3.amazonaws.com/videowires/1659596902_1.mp4"));
//
//   @override
//   void initState() {
//     imgLink?.value = widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg');
//
//     // videoPlayerController = VideoPlayerController.network(widget.videoLink, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
//     // init().whenComplete(() {
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     // TODO: implement initState
//     // _controller = VideoPlayerController.network(widget.videoLink, videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: false, mixWithOthers: false))
//     //   ..initialize().then((_) {
//     //     // setState(() {});
//     //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//     //   });
//
//     super.initState();
//   }
//
//   Future init() async {
//     // await videoPlayerController.initialize();
//     // chewieController = ChewieController(
//     //   videoPlayerController: videoPlayerController,
//     //   autoPlay: false,
//     //   autoInitialize: true,
//     //   showControls: true,
//     //   allowPlaybackSpeedChanging: false,
//     //   allowedScreenSleep: false,
//     //   allowMuting: false,
//     //   // aspectRatio: 1 ?? videoPlayerController.value.aspectRatio,
//     //   fullScreenByDefault: false,
//     //   allowFullScreen: true,
//     //   showOptions: true,
//     //   zoomAndPan: true,
//     //
//     //   // placeholder: Image.asset(AppImages.logoImage),
//     //   looping: false,
//     // );
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     // _controller.dispose();
//     // chewieController.dispose();
//     // videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   RxBool thumbnail = true.obs;
//   double videocontainerratio = 0.5;
//
//   // double getscale() {
//   //   double videoratio = videoPlayerController.value.aspectRatio;
//   //
//   //   if (videoratio < videocontainerratio) {
//   //     ///for tall videos, we just return the inverse of the controller aspect ratio
//   //     return videocontainerratio / videoratio;
//   //   } else {
//   //     ///for wide videos, divide the video ar by the fixed container ar
//   //     ///so that the video does not over scale
//   //
//   //     return videoratio / videocontainerratio;
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return OverriddenAspectRatioPage(
//       videoLink: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//     );
//     print(">>> VIDEO PLAYER ${widget.videoLink}");
//     // return StreamBuilder(
//     //   stream: thumbnail.stream,
//     //   builder: (context, snapshot) {
//     //     if (thumbnail.value) {
//     //       print('====${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}');
//     //       return Stack(
//     //         fit: StackFit.expand,
//     //         children: [
//     //           CachedNetworkImage(
//     //             imageUrl: '${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}',
//     //             fit: BoxFit.cover,
//     //             errorWidget: (context, url, error) {
//     //               return Center(child: Icon(Icons.error));
//     //             },
//     //           ),
//     //           InkWell(
//     //             onTap: () {
//     //               thumbnail.value = false;
//     //               // videoPlayerController = VideoPlayerController.network(widget.videoLink);
//     //               // init().whenComplete(() {
//     //               //   setState(() {
//     //               //     if (videoPlayerController.value.isInitialized) {
//     //               //       chewieController.play();
//     //               //     }
//     //               //   });
//     //               // });
//     //             },
//     //             child: Align(
//     //               alignment: Alignment.center,
//     //               child: Icon(Icons.play_circle, color: Colors.white, size: 50),
//     //             ),
//     //           ),
//     //         ],
//     //       );
//     //     }
//         return StreamBuilder(
//           builder: (context, snapshot) {
//             RxBool loading = true.obs;
//             return StreamBuilder(
//               // stream: loading.stream,
//               builder: (context, snapshot) {
//                 // RxBool thumbnails = true.obs;
//                 // Future.delayed(
//                 //   const Duration(milliseconds: 500),
//                 //   () => loading.value = false,
//                 // );
//                 // if (loading.value == true) {
//                 //   return const Center(child: CupertinoActivityIndicator());
//                 // }
//
//                 return videoPlayerController.value.isInitialized
//                     ? AspectRatio(
//                         aspectRatio: getscale(),
//                         child: Chewie(
//                           controller: chewieController,
//                         ),
//                       )
//                     : const Center(child: CupertinoActivityIndicator());
//                 return videoPlayerController.value.isInitialized
//                     ? Chewie(
//                         controller: chewieController,
//                       )
//                     : const Center(child: CupertinoActivityIndicator());
//               },
//             );
//           },
//         );
//       },
//     );
//     // return videoPlayerController.value.isInitialized
//     //     ? Chewie(
//     //         controller: chewieController,
//     //       )
//     //     : const Center(child: CupertinoActivityIndicator());
//   }
// }

class CommonVideoPlayer extends StatefulWidget {
  final String videoLink;
  final bool? isFile;

  const CommonVideoPlayer({Key? key, required this.videoLink, this.isFile}) : super(key: key);

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayer();
}

class _CommonVideoPlayer extends State<CommonVideoPlayer> {
  late FlickManager flickManager;
  RxBool thumbnail = true.obs;

  @override
  void initState() {
    super.initState();
    log("==== LINK OF PLAYER ${widget.videoLink}");
    if (widget.isFile == true) {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.file(File(widget.videoLink)),
          autoInitialize: true,
          onVideoEnd: () {
            // thumbnail.value = true;
          });
    } else {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(
            widget.videoLink, 
          ),
          autoInitialize: true,
          autoPlay: true,
          onVideoEnd: () {
            thumbnail.value = true;
          });
    }
  }

  @override
  void dispose() {
    flickManager.dispose();
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
          if (thumbnail.value) {
            print('====${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}');
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: '${widget.videoLink.replaceAll("videowires", 'videothumbnails').replaceAll('mp4', 'jpg')}',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Center(child: Icon(Icons.error));
                  },
                ),
                InkWell(
                  onTap: () {
                    thumbnail.value = false;
                    // videoPlayerController = VideoPlayerController.network(widget.videoLink);
                    // init().whenComplete(() {
                    //   setState(() {
                    //     if (videoPlayerController.value.isInitialized) {
                    //       chewieController.play();
                    //     }
                    //   });
                    // });
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.play_circle, color: Colors.white, size: 50),
                  ),
                ),
              ],
            );
          }
          return Builder(
            builder: (context) {
              RxBool loading = true.obs;
              return Builder(
                // stream: loading.stream,
                builder: (context) {
                  // RxBool thumbnails = true.obs;
                  // Future.delayed(
                  //   const Duration(milliseconds: 500),
                  //   () => loading.value = false,
                  // );
                  // if (loading.value == true) {
                  //   return const Center(child: CupertinoActivityIndicator());
                  // }

                  return Container(
                    child: FlickVideoPlayer(
                      flickManager: flickManager,
                      preferredDeviceOrientationFullscreen: [DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft],
                      preferredDeviceOrientation: [DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft],
                      systemUIOverlayFullscreen: [SystemUiOverlay.bottom],
                      systemUIOverlay: [SystemUiOverlay.top],
                    ),
                  );
                },
              );
            },
          );
        });
  }
}
