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
  RxBool _isFullScreen = false.obs;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: false,
        loop: false,
      ),
    );
    _controller.setFullScreenListener(
      (isFullScreen) {
        print(isFullScreen);
        _isFullScreen.value = isFullScreen;
        _isFullScreen.refresh();
        if (isFullScreen == false) {
        } else {
          _isFullScreen.value = true;
          _isFullScreen.refresh();
          setState(() {});
        }
      },
    );
  }

  Widget switchToFullscreen({required Widget play, required bool fullScreen}) {
    print(fullScreen);
    print(_isFullScreen.value);
    if (fullScreen == true) {
      print("Full Screen");
      // _overlayEntry = OverlayEntry(builder: (context) {
      //   return play;
      // });

      // Overlay.of(context).insert(_overlayEntry!);
      // _setSystemUIOverlays(hide: true);
    }

    return play;
  }

  _exitFullscreen() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _setSystemUIOverlays(hide: false);
  }

  void _setSystemUIOverlays({bool hide = true}) {
    if (hide) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: []); // Hide both status and navigation bars
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom
        ], // Show both bars
      );
    }
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
            if (MediaQuery.of(context).orientation == Orientation.landscape) {
              print("Full Screen");

              Future.delayed(Duration.zero, () {
                _overlayEntry = OverlayEntry(builder: (context) {
                  return player;
                });
                Overlay.of(context)?.insert(_overlayEntry!);
                _setSystemUIOverlays(hide: true);
              });

              return Container();
            } else {
              return player;
            }
          },
        );
      });
    });
  }
}
