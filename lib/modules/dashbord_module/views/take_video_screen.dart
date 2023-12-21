// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_texts.dart';

class TakeVideoScreen extends StatefulWidget {
  const TakeVideoScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakeVideoScreenState createState() => TakeVideoScreenState();
}

class TakeVideoScreenState extends State<TakeVideoScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  RxInt currentCamera = 0.obs;
  RxBool _isRecording = false.obs;
  RxInt min = 00.obs;
  double _scale = 1.0;

  RxInt seconds = 00.obs;
  Timer? timer;

  Future<void> changeCamera() async {
    final cameras = await availableCameras();
    print(" Camera List is ${cameras.length}");
    if (currentCamera.value == (cameras.length - 1)) {
      currentCamera.value = 0;
    } else {
      currentCamera.value++;
    }
    print(" CURRENT Camera ${currentCamera.value}");
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[currentCamera.value],
      // Define the resolution to use.
      ResolutionPreset.high,
    );
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,

      // Define the resolution to use.
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a video'), actions: [
        StreamBuilder(
            stream: _isRecording.stream,
            builder: (context, snapshot) {
              if (_isRecording.isFalse) {
                return IconButton(
                  onPressed: () async {
                    await changeCamera();
                    _initializeControllerFuture = _controller.initialize();
                    setState(() {});
                  },
                  icon: const Icon(Icons.cameraswitch_outlined),
                );
              } else {
                return const SizedBox();
              }
            })
      ]),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onScaleUpdate: (details) async {
                    var maxZoomLevel = await _controller.getMaxZoomLevel();
                    var minZoomLevel = await _controller.getMinZoomLevel();

                    // just calling it dragIntensity for now, you can call it whatever you like.
                    var dragIntensity = details.scale;
                    if (dragIntensity < 1) {
                      // 1 is the minimum zoom level required by the camController's method, hence setting 1 if the user zooms out (less than one is given to details when you zoom-out/pinch-in).
                      _controller.setZoomLevel(1);
                    } else if (dragIntensity > 1 && dragIntensity < maxZoomLevel) {
                      // self-explanatory, that if the maxZoomLevel exceeds, you will get an error (greater than one is given to details when you zoom-in/pinch-out).
                      _controller.setZoomLevel(dragIntensity);
                    }
                    // } else {
                    //   // if it does exceed, you can provide the maxZoomLevel instead of dragIntensity (this block is executed whenever you zoom-in/pinch-out more than the max zoom level).
                    //   _controller.setZoomLevel(minZoomLevel);
                    // }
                  },
                  child: CameraPreview(
                    _controller,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: StreamBuilder(
                      stream: seconds.stream,
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Text(
                            "$min : $seconds",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: "OpenSans",
                            ),
                          ),
                        );
                      }),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    width: 35,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: () async {
                              _scale = (_scale >= await _controller.getMaxZoomLevel()) ? _scale : _scale + 1;
                              print(" SCALE IS ${_scale}");
                              _controller.setZoomLevel(_scale);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.add, color: Colors.black),
                            )),
                        Divider(color: Colors.black),
                        InkWell(
                            onTap: () {
                              _scale = _scale <= 1 ? 1.0 : _scale - 1;
                              print(" SCALE IS ${_scale}");
                              _controller.setZoomLevel(_scale);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.remove, color: Colors.black),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "You posting something by agreeing",
                style: TextStyle(color: Colors.red),
              ),
              InkWell(
                  onTap: () async {
                    await launch(
                      AppTexts.eulaLink,
                    );
                  },
                  child: const Text(
                    " EULA",
                    style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),
                  )),
            ],
          ),
          FloatingActionButton(
            // Provide an onPressed callback.
            onPressed: () async {
              _recordVideo();
            },
            // child: const Icon(Icons.camera_alt),
            child: Icon(_isRecording.value ? Icons.stop : Icons.circle, color: _isRecording.value ? Colors.red : Colors.blue),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _recordVideo() async {
    if (_isRecording.value) {
      final file = await _controller.stopVideoRecording();
      endTimer();
      setState(() => _isRecording.value = false);
      print("==== ${file.path.split("/").last}");

      Get.back(result: File(file.path));
      // Get.to(() => VideoPage(filePath: file.path));
    } else {
      await _controller.prepareForVideoRecording();
      await _controller.startVideoRecording();
      startTimer();
      setState(() => _isRecording.value = true);
    }
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds.value < 60) {
        seconds.value++;
      } else {
        seconds.value = 0;
        min.value++;
      }
    });
  }

  endTimer() {
    timer?.cancel();
    seconds.value = 0;
    min.value = 0;
  }
}

// A widget that displays the picture taken by the user.
class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;

  const DisplayVideoScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(videoPath)),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, label: const Icon(Icons.upload)),
    );
  }
}

// class VideoPage extends StatefulWidget {
//   final String filePath;
//
//   const VideoPage({Key? key, required this.filePath}) : super(key: key);
//
//   @override
//   _VideoPageState createState() => _VideoPageState();
// }
//
// class _VideoPageState extends State<VideoPage> {
//   // late VideoPlayerController _videoPlayerController;
//
//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   // Future _initVideoPlayer() async {
//   //   _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
//   //   await _videoPlayerController.initialize();
//   //   await _videoPlayerController.setLooping(true);
//   //   await _videoPlayerController.play();
//   // }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Preview'),
//         elevation: 0,
//         backgroundColor: Colors.black26,
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.check),
//           //   onPressed: () {
//           //
//           //     // kDashboardController.dashboardFeeds?.clear();
//           //     // kDashboardController.dashBoardLoadFeeds(page: 0, isFirstTimeLoading: true, isShowProcess: true);
//           //   },
//           // )
//         ],
//       ),
//       extendBodyBehindAppBar: true,
//       body: FutureBuilder(
//         future: _initVideoPlayer(),
//         builder: (context, state) {
//           if (state.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else {
//             return VideoPlayer(_videoPlayerController);
//           }
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: MaterialButton(
//         onPressed: () {
//           kDashboardController.uploadImage(
//               imageFilePaths: [File(widget.filePath)],
//               callBack: () {
//                 Get.offAll(() => const DashBoardScreen());
//               });
//         },
//         padding: EdgeInsets.all(10),
//         color: Colors.blue,
//         child: Text("Upload"),
//       ),
//     );
//   }
// }
