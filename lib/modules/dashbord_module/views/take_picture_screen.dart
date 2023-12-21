// A screen that allows users to take a picture using a given camera.
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wghdfm_java/utils/app_binding.dart';

import 'dash_board_screen.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  RxInt currentCamera = 0.obs;
  RxBool isFront = false.obs;
  double _scale = 1.0;

  Future<void> changeCamera() async {
    final cameras = await availableCameras();
  /*  if (isFront.isTrue) {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      isFront.value = false;
    } else {
      _controller = CameraController(
        cameras.last,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      isFront.value = true;
    }*/
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
    _controller.dispose();
    super.dispose();
  }

  RxBool orientations = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture'), actions: [
        IconButton(
          onPressed: () async {
            await changeCamera();
            _controller.initialize().then((value) {
              setState(() {});
            });
          },
          icon: const Icon(Icons.cameraswitch_outlined),
        )
      ]),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
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
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            final file = File(image.path);

            if (!mounted) return;
            Get.back(result: file);

            // If the picture was taken, display it on a new screen.
            // Get.to(() => DisplayPictureScreen(
            //       imagePath: image.path,
            //     ));
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            kDashboardController.uploadImage(
                imageFilePaths: [File(imagePath)],
                callBack: () {
                  Get.offAll(() => const DashBoardScreen());
                });
            // kDashboardController.dashBoardLoadFeeds(page: 0, isFirstTimeLoading: true, isShowProcess: true);
          },
          label: const Icon(Icons.upload)),
    );
  }
}
