import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wghdfm_java/modules/auth_module/model/login_model.dart';
import 'package:wghdfm_java/modules/dashbord_module/controller/dash_board_controller.dart';
import 'package:wghdfm_java/modules/dashbord_module/views/take_picture_screen.dart';
import 'package:wghdfm_java/modules/profile_module/controller/profile_controller.dart';
import 'package:wghdfm_java/services/sesssion.dart';
import 'package:wghdfm_java/utils/app_methods.dart';
import 'package:wghdfm_java/utils/button.dart';

class ProfileSetupPage extends StatefulWidget {
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int step =
      1; // Track the current step (1 for profile photo, 2 for cover photo, 3 for the first post).

  final profileController = Get.put(ProfileController());

  Future<void> nextStep() async {
    if (step == 1 && _profileImage != null) {
      LoginModel userDetails = await SessionManagement.getUserDetails();
      userId = userDetails.id;
      profileController.updateProfileImage(
          userIdCurrent: userId, image: _profileImage!, isProfile: true);
    }
    if (step == 2 && _coverImage != null) {
      LoginModel userDetails = await SessionManagement.getUserDetails();
      userId = userDetails.id;
      profileController.updateProfileImage(
          userIdCurrent: userId, image: _coverImage!, isProfile: false);
      Get.back();
    } else if (step == 2) {
      Get.back();
    }
    setState(() {
      if (step < 2) {
        step++;
      }
    });
  }

  void backStep() {
    setState(() {
      if (step > 1) {
        step--;
      }
    });
  }

  File? _profileImage;
  File? _coverImage;

  Future<void> _pickProfileImage() async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final image = await FilePicker.platform.pickFiles(
        allowCompression: false,
        withReadStream: true,
        allowMultiple: false,
        withData: false,
        dialogTitle: "Pick Profile Image",
        type: FileType.media);

    if (image != null) {
      setState(() {
        _profileImage = File(image.files.first.path!);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final image = await FilePicker.platform.pickFiles(
        allowCompression: false,
        withReadStream: true,
        allowMultiple: false,
        withData: false,
        dialogTitle: "Pick Cover Image",
        type: FileType.media);

    if (image != null) {
      setState(() {
        _coverImage = File(image.files.first.path!);
      });
    }
  }

  addPhotoScreen() async {
    bool per = await AppMethods().getPermission();

    if (per == true) {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      Get.to(() => TakePictureScreen(
            camera: firstCamera,
          ))?.then((value) {
        _profileImage = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Setup'),
          leading: SizedBox(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                if (step == 1) ...[
                  Text(
                    "Step 1: Upload a Profile Photo",
                    style: TextStyle(fontSize: 24.0),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              'No Photo',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: _pickProfileImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        Text(
                          'Select Profile Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addPhotoScreen,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera, color: Colors.white),
                        Text(
                          'Click Profile Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Why you should upload a profile picture..?',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'A profile picture is your digital representation on our Christian social media platform. Uploading a photo allows others to recognize and connect with you more easily.',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                ],
                if (step == 2) ...[
                  Text(
                    "Step 2: Upload a Cover Photo",
                    style: TextStyle(fontSize: 24.0),
                  ),
                  Container(
                    width: 350,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    child: _coverImage != null
                        ? Image.file(
                            _coverImage!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              'No Photo',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: _pickCoverImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        Text(
                          'Select Cover Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Why you should upload a Cover Image..?',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "A cover picture is an opportunity to showcase your faith, interests, or personality in a larger image format. It's like the banner for your profile.",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                ],
                if (step <= 2)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (step != 1)
                        ElevatedButton(
                          onPressed: backStep,
                          child: Text(
                            "Back",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (step != 2 && _profileImage != null)
                        ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(),
                          child: Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                      if (step != 1 && _coverImage != null)
                        ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(),
                          child: Text(
                            "Complete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      // ElevatedButton(
                      //   onPressed: nextStep,
                      //   child: Text("Skip"),
                      // ),
                    ],
                  ),
                SizedBox(height: Get.height * 0.02)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePhotoUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add your profile photo upload screen here
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Profile Photo"),
      ),
      body: Center(
        child: Text("Profile Photo Upload Page"),
      ),
    );
  }
}

class CoverPhotoUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add your cover photo upload screen here
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Cover Photo"),
      ),
      body: Center(
        child: Text("Cover Photo Upload Page"),
      ),
    );
  }
}

class FirstPostSharePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add your first post sharing screen here
    return Scaffold(
      appBar: AppBar(
        title: Text("Share Your First Post"),
      ),
      body: Center(
        child: Text("First Post Share Page"),
      ),
    );
  }
}
