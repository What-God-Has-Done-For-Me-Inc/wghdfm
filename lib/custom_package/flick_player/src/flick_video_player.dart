import 'dart:convert';

import 'package:universal_html/html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wghdfm_java/custom_package/flick_player/src/utils/web_key_bindings.dart';
import 'package:http/http.dart' as http;
import 'controls/flick_portrait_controls.dart';
import 'controls/flick_video_with_controls.dart';
import 'manager/flick_manager.dart';
import 'model/models.dart';
import 'utils/file_utils.dart';
import 'utils/flick_manager_builder.dart';
import 'utils/regex_response.dart';
import 'widgets/video_quality_picker.dart';

class FlickVideoPlayer extends StatefulWidget {
  FlickVideoPlayer({
    Key? key,
    required this.flickManager,
    this.flickVideoWithControls = const FlickVideoWithControls(
      controls: FlickPortraitControls(),
    ),
    this.flickVideoWithControlsFullscreen,
    this.systemUIOverlay = SystemUiOverlay.values,
    this.systemUIOverlayFullscreen = const [],
    this.preferredDeviceOrientation = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    this.preferredDeviceOrientationFullscreen = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ],
    this.WakelockEnabled = true,
    this.WakelockEnabledFullscreen = true,
    this.webKeyDownHandler = flickDefaultWebKeyDownHandler,
    this.onShowMenu,
  }) : super(key: key);

  final FlickManager flickManager;

  /// Widget to render video and controls.
  final Widget flickVideoWithControls;

  /// Widget to render video and controls in full-screen.
  final Widget? flickVideoWithControlsFullscreen;

  /// SystemUIOverlay to show.
  ///
  /// SystemUIOverlay is changed in init.
  final List<SystemUiOverlay> systemUIOverlay;

  /// SystemUIOverlay to show in full-screen.
  final List<SystemUiOverlay> systemUIOverlayFullscreen;

  /// Preferred device orientation.
  ///
  /// Use [preferredDeviceOrientationFullscreen] to manage orientation for full-screen.
  final List<DeviceOrientation> preferredDeviceOrientation;

  /// Callback function for showing menu event.
  final void Function(bool showMenu, bool m3u8Show)? onShowMenu;

  /// Preferred device orientation in full-screen.
  final List<DeviceOrientation> preferredDeviceOrientationFullscreen;

  /// Prevents the screen from turning off automatically.
  ///
  /// Use [WakelockEnabledFullscreen] to manage Wakelock for full-screen.
  final bool WakelockEnabled;

  /// Prevents the screen from turning off automatically in full-screen.
  final bool WakelockEnabledFullscreen;

  /// Callback called on keyDown for web, used for keyboard shortcuts.
  final Function(KeyboardEvent, FlickManager) webKeyDownHandler;

  @override
  _FlickVideoPlayerState createState() => _FlickVideoPlayerState();
}

class _FlickVideoPlayerState extends State<FlickVideoPlayer>
    with WidgetsBindingObserver {
  late FlickManager flickManager;
  bool _isFullscreen = false;

  OverlayEntry? _overlayEntry;
  double? _videoWidth;
  double? _videoHeight;

  /// Video quality overlay
  OverlayEntry? overlayEntry;

  /// m3u8 data video list for user choice
  List<M3U8Data> videoModel = [];

  /// m3u8 audio list
  List<AudioModel> audioList = [];

  /// m3u8 temp data
  String? m3u8Content;

  /// Global key to calculate quality options
  GlobalKey videoQualityKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    widget.flickManager.registerContext(context);
    flickManager = widget.flickManager;
    flickManager.registerContext(context);
    flickManager.flickControlManager!.addListener(listener);
    flickManager.flickDisplayManager!.addListener(listener1);
    _setSystemUIOverlays();
    _setPreferredOrientation();

    if (widget.WakelockEnabled) {
      Wakelock.enable();
    }

    if (kIsWeb) {
      document.documentElement?.onFullscreenChange
          .listen(_webFullscreenListener);
      document.documentElement?.onKeyDown.listen(_webKeyListener);
    }

    if (widget.flickManager.videoUrl != null) {
      getM3U8(flickManager.videoUrl!);
    }

    super.initState();
  }

  @override
  void dispose() {
    flickManager.flickControlManager!.removeListener(listener);
    if (widget.WakelockEnabled) {
      Wakelock.disable();
    }
    WidgetsBinding.instance.removeObserver(this);
    m3u8Clean();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_overlayEntry != null) {
      flickManager.flickControlManager!.exitFullscreen();
      return true;
    }
    return false;
  }

  // Listener on [FlickControlManager],
  // Pushes the full-screen if [FlickControlManager] is changed to full-screen.
  void listener() async {
    if (flickManager.flickControlManager!.isFullscreen && !_isFullscreen) {
      _switchToFullscreen();
    } else if (_isFullscreen &&
        !flickManager.flickControlManager!.isFullscreen) {
      _exitFullscreen();
    }
  }

  void listener1() async {
    if (flickManager.flickDisplayManager!.showQualityControls == true) {
      print("show Dailog");
      showOverlay();
    } else if (flickManager.flickDisplayManager!.showQualityControls == false) {
      print("hide Dailog");
      removeOverlay();
    }
  }

  /// M3U8 Data Setup
  void getM3U8(String videoUrl) {
    final uri = Uri.parse(videoUrl);
    if (videoModel.isNotEmpty) {
      print("${videoModel.length} : data start clean");
      m3u8Clean();
    }
    print("---- m3u8 fitch start ----\n$videoUrl\n--- please wait –––");
    if (uri.pathSegments.last.endsWith("m3u8")) {
      print("urlEnd: M3U8");

      m3u8Video(videoUrl);
      setState(() {
        flickManager.flickDisplayManager!.handelQualityButton(show: true);
      });
    }
  }

  Future<M3U8s?> m3u8Video(String? videoUrl) async {
    videoModel.add(M3U8Data(dataQuality: "Auto", dataURL: videoUrl));
    RegExp regExp = RegExp(
      RegexResponse.regexM3U8Resolution,
      caseSensitive: false,
      multiLine: true,
    );

    if (m3u8Content != null) {
      print("--- HLS Old Data ----\n$m3u8Content");
      m3u8Content = null;
    }

    if (m3u8Content == null && videoUrl != null) {
      http.Response response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        m3u8Content = utf8.decode(response.bodyBytes);

        List<RegExpMatch> matches =
            regExp.allMatches(m3u8Content ?? '').toList();
        print(
            "--- HLS Data ----\n$m3u8Content \nTotal length: ${videoModel.length} \nFinish!!!");

        for (RegExpMatch regExpMatch in matches) {
          String quality = (regExpMatch.group(1)).toString();
          String sourceURL = (regExpMatch.group(3)).toString();
          final netRegex = RegExp(RegexResponse.regexHTTP);
          final netRegex2 = RegExp(RegexResponse.regexURL);
          final isNetwork = netRegex.hasMatch(sourceURL);
          final match = netRegex2.firstMatch(videoUrl);
          String url;
          if (isNetwork) {
            url = sourceURL;
          } else {
            print(
                'Match: ${match?.pattern} --- ${match?.groupNames} --- ${match?.input}');
            final dataURL = match?.group(0);
            url = "$dataURL$sourceURL";
            print("--- HLS child url integration ---\nChild url :$url");
          }
          for (RegExpMatch regExpMatch2 in matches) {
            String audioURL = (regExpMatch2.group(1)).toString();
            final isNetwork = netRegex.hasMatch(audioURL);
            final match = netRegex2.firstMatch(videoUrl);
            String auURL = audioURL;

            if (!isNetwork) {
              print(
                  'Match: ${match?.pattern} --- ${match?.groupNames} --- ${match?.input}');
              final auDataURL = match!.group(0);
              auURL = "$auDataURL$audioURL";
              print("Url network audio  $url $audioURL");
            }

            audioList.add(AudioModel(url: auURL));
            print(audioURL);
          }

          String audio = "";
          print("-- Audio ---\nAudio list length: ${audio.length}");
          if (audioList.isNotEmpty) {
            audio =
                """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",
                  URI="${audioList.last.url}"\n""";
          } else {
            audio = "";
          }

          videoModel.add(M3U8Data(dataQuality: quality, dataURL: url));
        }
        M3U8s m3u8s = M3U8s(m3u8s: videoModel);

        print(
            "--- m3u8 File write --- ${videoModel.map((e) => e.dataQuality == e.dataURL).toList()} --- length : ${videoModel.length} --- Success");
        return m3u8s;
      }
    }

    return null;
  }

  void m3u8Clean() async {
    print('Video list length: ${videoModel.length}');
    for (int i = 2; i < videoModel.length; i++) {
      try {
        var file = await FileUtils.readFileFromPath(
            videoUrl: videoModel[i].dataURL ?? '',
            quality: videoModel[i].dataQuality ?? '');
        var exists = await file?.exists();
        if (exists ?? false) {
          await file?.delete();
          print("Delete success $file");
        }
      } catch (e) {
        print("Couldn't delete file $e");
      }
    }
    try {
      print("Cleaning audio m3u8 list");
      audioList.clear();
      print("Cleaning audio m3u8 list completed");
    } catch (e) {
      print("Audio list clean error $e");
    }
    audioList.clear();
    try {
      print("Cleaning m3u8 data list");
      videoModel.clear();
      print("Cleaning m3u8 data list completed");
    } catch (e) {
      print("m3u8 video list clean error $e");
    }
  }

  /// Video quality list
  Widget m3u8List() {
    RenderBox? renderBox =
        videoQualityKey.currentContext?.findRenderObject() as RenderBox?;
    var offset = renderBox?.localToGlobal(Offset.zero);

    return VideoQualityPicker(
      videoData: videoModel,
      showPicker: flickManager.flickDisplayManager!.showQualityControls,
      positionRight: (renderBox?.size.width ?? 0.0) / 2,
      positionBottom: (offset?.dy ?? 0.0) + 35.0,
      onQualitySelected: (m3u8data) {
        if (m3u8data.dataQuality !=
            flickManager.flickDisplayManager!.m3u8Quality) {
          setState(() {
            flickManager.flickDisplayManager!.m3u8Quality =
                m3u8data.dataQuality ??
                    flickManager.flickDisplayManager!.m3u8Quality;
          });
          handleSelectQuality(data: m3u8data);
          print(
              "--- Quality select ---\nquality : ${m3u8data.dataQuality}\nlink : ${m3u8data.dataURL}");
        }

        setState(() {
          flickManager.flickDisplayManager!.handeleQualityTap();
        });
        removeOverlay();
      },
    );
  }

  void handleSelectQuality({required M3U8Data data}) async {
    var lastPlayedPos =
        await flickManager.flickVideoManager!.videoPlayerController!.position;

    if (flickManager
        .flickVideoManager!.videoPlayerController!.value.isPlaying) {
      await flickManager.flickVideoManager!.videoPlayerController!.pause();
    }

    var controller = VideoPlayerController.networkUrl(
      Uri.parse(data.dataURL!),
      formatHint: VideoFormat.hls,
    );

    flickManager.handleChangeVideo(controller,
        videoChangeDuration: lastPlayedPos);
    flickManager.flickVideoManager!.videoPlayerController!.play();
  }

  showOverlay() {
    setState(() {
      overlayEntry = OverlayEntry(
        builder: (_) => m3u8List(),
      );
      Overlay.of(context).insert(overlayEntry!);
    });
  }

  void removeOverlay() {
    setState(() {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  _switchToFullscreen() {
    if (widget.WakelockEnabledFullscreen) {
      /// Disable previous Wakelock setting.
      Wakelock.disable();
      Wakelock.enable();
    }

    _isFullscreen = true;
    _setPreferredOrientation();
    _setSystemUIOverlays();
    if (kIsWeb) {
      document.documentElement?.requestFullscreen();
      Future.delayed(Duration(milliseconds: 100), () {
        _videoHeight = MediaQuery.of(context).size.height;
        _videoWidth = MediaQuery.of(context).size.width;
        setState(() {});
      });
    } else {
      _overlayEntry = OverlayEntry(builder: (context) {
        return Scaffold(
          body: FlickManagerBuilder(
            flickManager: flickManager,
            child: widget.flickVideoWithControlsFullscreen ??
                widget.flickVideoWithControls,
          ),
        );
      });

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  _exitFullscreen() {
    if (widget.WakelockEnabled) {
      /// Disable previous Wakelock setting.
      Wakelock.disable();
      Wakelock.enable();
    }

    _isFullscreen = false;

    if (kIsWeb) {
      document.exitFullscreen();
      _videoHeight = null;
      _videoWidth = null;
      setState(() {});
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _setPreferredOrientation();
    _setSystemUIOverlays();
  }

  _setPreferredOrientation() {
    // when aspect ratio is less than 1 , video will be played in portrait mode and orientation will not be changed.
    var aspectRatio =
        widget.flickManager.flickVideoManager!.videoPlayerValue!.aspectRatio;
    if (_isFullscreen && aspectRatio >= 1) {
      SystemChrome.setPreferredOrientations(
          widget.preferredDeviceOrientationFullscreen);
    } else {
      SystemChrome.setPreferredOrientations(widget.preferredDeviceOrientation);
    }
  }

  _setSystemUIOverlays() {
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: widget.systemUIOverlayFullscreen);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: widget.systemUIOverlay);
    }
  }

  void _webFullscreenListener(Event event) {
    final isFullscreen = (window.screenTop == 0 && window.screenY == 0);
    if (isFullscreen && !flickManager.flickControlManager!.isFullscreen) {
      flickManager.flickControlManager!.enterFullscreen();
    } else if (!isFullscreen &&
        flickManager.flickControlManager!.isFullscreen) {
      flickManager.flickControlManager!.exitFullscreen();
    }
  }

  void _webKeyListener(KeyboardEvent event) {
    widget.webKeyDownHandler(event, flickManager);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _videoWidth,
      height: _videoHeight,
      child: FlickManagerBuilder(
        flickManager: flickManager,
        child: widget.flickVideoWithControls,
      ),
    );
  }
}
