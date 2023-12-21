// import 'dart:async';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:whatgodhasdoneforme/utils/toast_me_not.dart';
//
// class CaptureImageVidController extends GetxController {
//   String? willShootVid;
//   late CameraController cameraController;
//   bool isFrontCamera = false;
//   late Future initializeControllerFuture;
//   late String path;
//
//   bool isRecording = false;
//   var args = Get.arguments;
//
//   @override
//   void onInit() {
//     if (args != null) {
//       willShootVid = args["0"];
//     }
//     super.onInit();
//   }
//
//   @override
//   void dispose() {
//     if (willShootVid! == "true") {
//       stopVideoRecording();
//     }
//     cameraController.dispose();
//     super.dispose();
//     super.dispose();
//   }
//
//   Future<void> stopVideoRecording() async {
//     if (!cameraController.value.isRecordingVideo) {
//       /*snack(
//           title: "Not recording...",
//           msg: "Start recording before stopping",
//           iconColor: Colors.yellow,
//           icon: Icons.info_outline);*/
//       //ToastMeNot.show("No ongoing recording", context, gravity: ToastMeNot.CENTER);
//       return;
//     }
//
//     if (cameraController.value.isRecordingVideo) {
//       try {
//         await initializeControllerFuture;
//
//         // Construct the path where the video should be saved using the
//         // pattern package.
//         path = join(
//           (await getTemporaryDirectory()).path,
//           '${DateTime.now()}.mp4',
//         );
//         // Attempt to take a picture and log where it's been saved.
//         XFile xFile = await cameraController.stopVideoRecording();
//         path = xFile.path;
//         resetWatch();
//         // ignore: use_build_context_synchronously
//         //todo : Pass context ToastMeNot.show("Recording stopped...",gravity: ToastMeNot.CENTER,
//         //     Get.context);
//       } on CameraException catch (e) {
//         return;
//       }
//     }
//   }
//
//   Stopwatch watch = Stopwatch();
//   late Timer timer;
//   bool isTimerRunning = false;
//   String elapsedTime = '';
//
//   updateTime(Timer timer) {
//     if (watch.isRunning) {
//       //setState(() {
//       debugPrint("isTimerRunning => $isTimerRunning");
//       elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
//       //});
//     }
//   }
//
//   setTime() {
//     var timeSoFar = watch.elapsedMilliseconds;
//
//     elapsedTime = transformMilliSeconds(timeSoFar);
//     update();
//   }
//
//   startWatch() {
//     //setState(() {
//     isTimerRunning = true;
//     watch.start();
//     timer = Timer.periodic(const Duration(milliseconds: 100), updateTime);
//     //});
//   }
//
//   stopWatch() {
//     //setState(() {
//     isTimerRunning = false;
//     watch.stop();
//     setTime();
//     //});
//   }
//
//   startOrStop() {
//     if (!isTimerRunning) {
//       startWatch();
//     } else {
//       stopWatch();
//     }
//   }
//
//   resetWatch() {
//     isTimerRunning = false;
//     watch.stop();
//     watch.reset();
//     timer.cancel();
//     setTime();
//   }
//
//   Future<bool> toggleTimer() async {
//     if (!isRecording) {
//       startWatch();
//     } else {
//       resetWatch();
//     }
//
//     return isRecording;
//   }
//
//   Future<void> startVideoRecording(BuildContext context) async {
//     if (!cameraController.value.isInitialized) {
//       ToastMeNot.show("Please wait...", context, gravity: ToastMeNot.CENTER);
//
//       return;
//     }
//
//     // Do nothing if a recording is in progress
//     if (cameraController.value.isRecordingVideo) {
//       ToastMeNot.show("Ongoing recording detected. ", context, gravity: ToastMeNot.CENTER);
//
//       return;
//     }
//
//     // set a location to save the recorded video, if no recording is in progress
//     if (!cameraController.value.isRecordingVideo) {
//       //final Directory appDirectory = await getApplicationDocumentsDirectory();
//       //final String videoDirectory = '${appDirectory.path}/Videos';
//       //await Directory(videoDirectory).create(recursive: true);
//       //final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//       //final String filePath = '$videoDirectory/${DateTime.now()}.mp4';
//       /*path = join(
//         // Store the picture in the temp directory.
//         // Find the temp directory using the `path_provider` plugin.
//         (await getTemporaryDirectory()).path,
//         '${DateTime.now()}.mp4',
//       );*/
//
//       try {
//         await cameraController.startVideoRecording();
//         startWatch();
//         /*snack(
//             title: "Recording...",
//             msg: "Started recording video",
//             iconColor: Colors.yellow,
//             icon: Icons.info_outline);*/
//
//         // ignore: use_build_context_synchronously
//         ToastMeNot.show("Recording...", context, gravity: ToastMeNot.CENTER);
//
//         //videoPath = filePath;
//       } on CameraException catch (e) {
//         print("Camera Exception $e");
//         return;
//       }
//     }
//   }
//
//   Future<bool> onExit(BuildContext context) async {
//     bool canExit = false;
//     if ("$willShootVid" == "true") {
//       bool onRoll = await getVideoRecordingStatus();
//       if (onRoll != null) {
//         canExit = false;
//         if (onRoll) {
//           // ignore: use_build_context_synchronously
//           ToastMeNot.show("Please stop the recording before exiting the screen.", context, gravity: ToastMeNot.CENTER);
//         } else {
//           canExit = true;
//           // ignore: use_build_context_synchronously
//           Navigator.pop(context);
//         }
//       } else {
//         canExit = true;
//
//         // ignore: use_build_context_synchronously
//         Navigator.pop(context);
//       }
//     } else {
//       canExit = true;
//
//       Navigator.pop(context);
//     }
//
//     return canExit;
//   }
//
//   Future<bool> getVideoRecordingStatus() async {
//     if (cameraController != null) {
//       if (cameraController.value.isInitialized) {
//         isRecording = cameraController.value.isRecordingVideo;
//       } else {
//         isRecording = false;
//       }
//     } else {
//       isRecording = false;
//     }
//     return isRecording;
//   }
//
//   Future<List<CameraDescription>> initImgVidCapture() async {
//     // Ensure that plugin services are initialized so that `availableCameras()`
//     // can be called before `runApp()`
//     WidgetsFlutterBinding.ensureInitialized();
//
//     // Obtain a list of the available cameras on the device.
//     final cameras = await availableCameras();
//
//     // Get a specific camera from the list of available cameras.
//     //final rearCamera = cameras.first; //rear camera
//     //final frontCamera = cameras.last; //front camera
//
//     return cameras;
//   }
//
//   Future<void> initCamera() async {
//     // To display the current output from the Camera,
//     // create a CameraController.
//     CameraDescription camera;
//     List<CameraDescription> cameras = await initImgVidCapture();
//     camera = isFrontCamera ? cameras.last : cameras.first;
//     cameraController = CameraController(
//       // Get a specific camera from the list of available cameras.
//       camera,
//       // Define the resolution to use.
//       ResolutionPreset.high,
//       enableAudio: willShootVid == "true" ? true : false,
//     );
//
//     await cameraController.initialize();
//     // Next, initialize the controller. This returns a Future.
//     initializeControllerFuture = cameraController.initialize();
//   }
//
//   Future<void> snapImage(BuildContext context) async {
//     // Take the Picture in a try / catch block. If anything goes wrong,
//     // catch the error.
//     try {
//       // Ensure that the camera is initialized.
//       await initializeControllerFuture;
//
//       // Construct the path where the image should be saved using the
//       // pattern package.
//       path = join(
//         // Store the picture in the temp directory.
//         // Find the temp directory using the `path_provider` plugin.
//         (await getTemporaryDirectory()).path,
//         '${DateTime.now()}.png',
//       );
//
//       // Attempt to take a picture and log where it's been saved.
//       XFile xFile = await cameraController.takePicture();
//       // File tookedPictures = File(xFile.path);
//       // await kDashboardController.uploadImage([tookedPictures]);
//       // Navigator.pop(context, path);
//
//       // Get.to(() => DisplayPictureScreen(
//       //       imagePath: xFile.path,
//       //     ));
//       // If the picture was taken, display it on a new screen.
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => DisplayPictureScreen(imagePath: path),
//       //   ),
//       // );
//     } catch (e) {
//       // If an error occurs, log the error to the console.
//       print(e);
//     }
//   }
// }
//
// transformMilliSeconds(int milliseconds) {
//   int hundreds = (milliseconds / 10).truncate();
//   int seconds = (hundreds / 100).truncate();
//   int minutes = (seconds / 60).truncate();
//
//   String minutesStr = (minutes % 60).toString().padLeft(2, '0');
//   String secondsStr = (seconds % 60).toString().padLeft(2, '0');
//
//   return "$minutesStr:$secondsStr";
// }
