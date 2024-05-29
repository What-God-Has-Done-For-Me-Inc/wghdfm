import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wghdfm_java/common/commons.dart';
import 'package:wghdfm_java/model/feed_res_obj.dart';
import 'package:wghdfm_java/utils/app_binding.dart';
import 'package:wghdfm_java/utils/app_colors.dart';

class EditPostScreen extends StatefulWidget {
  final String? statusText;
  final String? ytVideoURL;
  final bool? isMediaPost;

  const EditPostScreen(
      {Key? key, this.statusText, this.ytVideoURL, this.isMediaPost})
      : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  TextEditingController statusController = TextEditingController();
  TextEditingController ytVideoController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    statusController.text = widget.statusText ?? "";
    ytVideoController.text = widget.ytVideoURL ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Post',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      // body: widget.isMediaPost == true
      //     ? MediaScreen(postId: ,)
      //     : ListView(shrinkWrap: false, children: [
      //         Container(
      //           padding: EdgeInsets.zero,
      //           color: Colors.transparent,
      //           child: Container(
      //             decoration: BoxDecoration(
      //               color: Colors.grey,
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.start,
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //                 Container(
      //                   padding: const EdgeInsets.only(
      //                     left: 5,
      //                     right: 5,
      //                   ),
      //                   child: commonTextField(
      //                     readOnly: false,
      //                     hint: 'Enter Your Status Here',
      //                     isLabelFloating: false,
      //                     inputType: TextInputType.multiline,
      //                     // controller: c.statusTEC,
      //                     borderColor: Theme.of(context).colorScheme.surface,
      //                     baseColor: Theme.of(context).colorScheme.surface,
      //                     isLastField: false,
      //                     obscureText: false,
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 3,
      //                 ),
      //                 Container(
      //                   padding: const EdgeInsets.only(
      //                     left: 5,
      //                     right: 5,
      //                   ),
      //                   child: commonTextField(
      //                     readOnly: false,
      //                     hint: 'Paste your youtube url here (optional)',
      //                     isLabelFloating: false,
      //                     inputType: TextInputType.url,
      //                     maxLines: null,
      //                     // controller: c.ytUrlTEC,
      //                     borderColor: Theme.of(context).colorScheme.surface,
      //                     baseColor: Theme.of(context).colorScheme.surface,
      //                     isLastField: true,
      //                     obscureText: false,
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 3,
      //                 ),
      //                 Container(
      //                   padding: const EdgeInsets.only(
      //                     left: 10,
      //                     right: 10,
      //                   ),
      //                   height: 40,
      //                   width: Get.width,
      //                   child: ElevatedButton(
      //                     onPressed: () {
      //                       // if (areFieldsFilled()) {
      //                       //   Get.back();
      //                       //   editPost(feed.id!, c.statusTEC.text.trim(), c.ytUrlTEC.text.trim()).then((_) {
      //                       //     onEdit!();
      //                       //   });
      //                       // }
      //                     },
      //                     child: Text(
      //                       "UPDATE",
      //                       textAlign: TextAlign.center,
      //                       style: GoogleFonts.montserrat(
      //                         color: Colors.white,
      //                         fontSize: 18,
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 10,
      //                 ),
      //               ],
      //             ),
      //           ),
      //         )
      //       ]),
    );
  }
}

class MediaScreen extends StatefulWidget {
  final String postId;
  PostModelFeed? feed;

  MediaScreen({Key? key, required this.postId, this.feed}) : super(key: key);

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  TextEditingController statusController = TextEditingController();

  pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images =
        await picker.pickMultiImage(requestFullMetadata: false);
    final RxList<File> imageFile = <File>[].obs;
    if (images.isNotEmpty) {
      for (var element in images) {
        imageFile.add(File(element.path));
      }
    }

    Get.back();
    kDashboardController.editImage(
      statusText: statusController.text,
      imageFilePaths: imageFile,
      postId: widget.postId,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    statusController.text = widget.feed?.status ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                commonTextField(
                  readOnly: false,
                  hint: 'Enter Your Status Here',
                  isLabelFloating: false,
                  // controller: c.statusTEC,
                  borderColor: AppColors.grey,
                  baseColor: AppColors.grey,
                  isLastField: false,
                  obscureText: false,
                  controller: statusController,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          pickImages();
                        },
                        child: Text("Add Media And Update Post")))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
