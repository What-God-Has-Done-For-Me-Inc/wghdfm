import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
      // params: const YoutubePlayerParams(
      //   showControls: true,
      //   mute: false,
      //   showFullscreenButton: true,
      //   loop: false,
      // ),
    );

    // _controller.loadVideoById(
    //   videoId: widget.videoId,
    //   startSeconds: 0,
    // );

    //_controller.pauseVideo();
  }

  @override
  void dispose() {
    // _controller.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      controlsTimeOut: const Duration(seconds: 5),
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
    // return YoutubePlayerScaffold(
    //   controller: _controller,
    //   autoFullScreen: false,
    //   enableFullScreenOnVerticalDrag: false,
    //   builder: (context, player) {
    //     return LayoutBuilder(
    //       builder: (context, constraints) {
    //         if (kIsWeb && constraints.maxWidth > 750) {
    //           return Row(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Column(
    //                 children: [
    //                   player,
    //                   const VideoPositionIndicator(),
    //                 ],
    //               ),
    //             ],
    //           );
    //         }

    //         return player;
    //       },
    //     );
    //   },
    // );
  }
}

// class Controls extends StatelessWidget {
//   ///
//   const Controls();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // MetaDataSection(),
//           // _space,
//           // SourceInputSection(),
//           // _space,
//           // PlayPauseButtonBar(),
//           // _space,
//           // const VideoPositionSeeker(),
//           // _space,
//           // PlayerStateSection(),
//         ],
//       ),
//     );
//   }

//   Widget get _space => const SizedBox(height: 10);
// }

// ///
// class VideoPositionIndicator extends StatelessWidget {
//   ///
//   const VideoPositionIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.ytController;

//     return StreamBuilder<YoutubeVideoState>(
//       stream: controller.videoStateStream,
//       initialData: const YoutubeVideoState(),
//       builder: (context, snapshot) {
//         final position = snapshot.data?.position.inMilliseconds ?? 0;
//         final duration = controller.metadata.duration.inMilliseconds;

//         return LinearProgressIndicator(
//           value: duration == 0 ? 0 : position / duration,
//           minHeight: 1,
//         );
//       },
//     );
//   }
// }

// ///
// class VideoPositionSeeker extends StatelessWidget {
//   ///
//   const VideoPositionSeeker({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var value = 0.0;

//     return Row(
//       children: [
//         const Text(
//           'Seek',
//           style: TextStyle(fontWeight: FontWeight.w300),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: StreamBuilder<YoutubeVideoState>(
//             stream: context.ytController.videoStateStream,
//             initialData: const YoutubeVideoState(),
//             builder: (context, snapshot) {
//               final position = snapshot.data?.position.inSeconds ?? 0;
//               final duration = context.ytController.metadata.duration.inSeconds;

//               value = position == 0 || duration == 0 ? 0 : position / duration;

//               return StatefulBuilder(
//                 builder: (context, setState) {
//                   return Slider(
//                     value: value,
//                     onChanged: (positionFraction) {
//                       value = positionFraction;
//                       setState(() {});

//                       context.ytController.seekTo(
//                         seconds: (value * duration).toDouble(),
//                         allowSeekAhead: true,
//                       );
//                     },
//                     min: 0,
//                     max: 1,
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
