// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:whatgodhasdoneforme/screen/dashboard/capture_img_vid_screen/capture_image_vide_controller.dart';
// import 'package:whatgodhasdoneforme/screen/dashboard/capture_img_vid_screen/widgets.dart';
// import 'package:whatgodhasdoneforme/utils/toast_me_not.dart';
//
// class CaptureImgVidScreen extends StatelessWidget {
//   CaptureImgVidScreen({Key? key}) : super(key: key);
//   final CaptureImageVidController c = Get.put(CaptureImageVidController());
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () => c.onExit(context),
//         child: Scaffold(
//           extendBodyBehindAppBar: true,
//           backgroundColor: Colors.black45.withOpacity(0.3),
//           extendBody: true,
//           appBar: AppBar(
//             leading: IconButton(
//               onPressed: () async {
//                 /*if (widget.willShootVid) {
//                 stopVideoRecording();
//               }
//               if (!widget.willShootVid) {
//                 Navigator.pop(context, path);
//               }*/
//                 c.onExit(context);
//               },
//               icon: const Icon(Icons.arrow_back),
//             ),
//             title: Text(
//               c.willShootVid == "true" ? "Record a video" : 'Take a photo',
//               style: GoogleFonts.montserrat(
//                 color: Colors.black,
//                 fontSize: 15,
//               ),
//             ),
//             actions: [
//               Container(
//                 margin: const EdgeInsets.only(right: 20),
//                 alignment: Alignment.center,
//                 child: InkWell(
//                   child: const Icon(Icons.switch_camera),
//                   // Provide an onPressed callback.
//                   onTap: () {
//                     if (c.willShootVid == "true") {
//                       if (!c.cameraController.value.isRecordingVideo) {
//                         //stopVideoRecording();
//                         c.isFrontCamera = !c.isFrontCamera;
//                         c.update();
//                       } else {
//                         ToastMeNot.show("Camera cannot be switched during video recording is underway.", context, gravity: ToastMeNot.CENTER);
//                       }
//                     } else {
//                       // c.cameraController
//                       c.isFrontCamera = !c.isFrontCamera;
//                       c.update();
//                     }
//                   },
//                 ),
//               ),
//             ],
//             elevation: 0,
//             centerTitle: true,
//             iconTheme: Theme.of(context).iconTheme,
//             backgroundColor: Theme.of(context).backgroundColor,
//           ),
//           // Wait until the controller is initialized before displaying the
//           // camera preview. Use a FutureBuilder to display a loading spinner
//           // until the controller has finished initializing.
//           body: FutureBuilder<void>(
//             future: c.initCamera(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 // display a loading indicator.
//                 return const Center();
//               }
//
//               return Stack(
//                 children: [
//                   FutureBuilder<void>(
//                     future: c.initializeControllerFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         // display a loading indicator.
//                         return const Center();
//                       }
//                       if (snapshot.hasError) {
//                         return Center(
//                             child: FloatingActionButton.extended(
//                           onPressed: () {
//                             c.update();
//                           },
//                           icon: const Icon(Icons.refresh),
//                           label: const Text("Retry"),
//                         ));
//                       }
//
//                       return Container(
//                         color: Colors.black,
//                         width: MediaQuery.of(context).size.width,
//                         height: MediaQuery.of(context).size.height,
//                         alignment: Alignment.center,
//                         child: CameraPreview(c.cameraController),
//                       );
//                     },
//                   ),
//                   Positioned(
//                     bottom: 60,
//                     right: 0,
//                     left: 0,
//                     child: Container(
//                       alignment: Alignment.center,
//                       height: 60,
//                       child: Container(
//                         margin: const EdgeInsets.only(left: 5, right: 5),
//                         alignment: Alignment.center,
//                         child: (c.willShootVid == "true" ? false : true)
//                             ? FloatingActionButton(
//                                 child: const Icon(Icons.camera_alt),
//                                 // Provide an onPressed callback.
//                                 onPressed: () {
//                                   c.snapImage(context);
//                                 },
//                               )
//                             : videoRecordingButton(),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           bottomNavigationBar: Container(
//             height: 40,
//           ),
//         ));
//   }
// }
