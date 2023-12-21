// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:whatgodhasdoneforme/screen/dashboard/capture_img_vid_screen/capture_image_vide_controller.dart';
//
// Widget videoRecordingButton() {
//   final CaptureImageVidController c = Get.put(CaptureImageVidController());
//   return StatefulBuilder(
//     builder: (context, setState) {
//       return StreamBuilder(
//         stream: Stream.periodic(const Duration(seconds: 1), (_) {
//           c.getVideoRecordingStatus();
//         }),
//         builder: (context, snapshot) {
//           /*if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }*/
//           return Container(
//             margin: const EdgeInsets.only(left: 5, right: 5),
//             alignment: Alignment.center,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 FloatingActionButton(
//                   child: Icon(c.isRecording ? Icons.stop : Icons.fiber_manual_record),
//                   // Provide an onPressed callback.
//                   onPressed: () {
//                     if (!c.isRecording) c.startVideoRecording(context);
//                     if (c.isRecording) {
//                       c.stopVideoRecording().then((_) => Navigator.pop(context, c.path));
//                     }
//                     //getVideoRecordingStatus();
//                     //setState(() {});
//                   },
//                 ),
//                 Container(
//                   alignment: Alignment.center,
//                   padding: const EdgeInsets.all(10),
//                   child: Text(c.elapsedTime,
//                       style: const TextStyle(
//                         fontSize: 25.0,
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                       )),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
