import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiKeybord extends StatefulWidget {
  final TextEditingController? textController;

  const EmojiKeybord({Key? key, this.textController}) : super(key: key);

  @override
  State<EmojiKeybord> createState() => _EmojiKeybordState();
}

class _EmojiKeybordState extends State<EmojiKeybord> {
  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      textEditingController: widget.textController,
      config: Config(
        columns: 7,
        // Issue: https://github.com/flutter/flutter/issues/28894
        emojiSizeMax: 38,
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.ACTIVITIES,
        bgColor: const Color(0xFFF2F2F2),
        indicatorColor: Colors.blue,
        iconColor: Colors.grey,
        iconColorSelected: Colors.blue,
        backspaceColor: Colors.blue,
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        enableSkinTones: false,
        // showRecentsTab: false,
        recentsLimit: 28,
        replaceEmojiOnLimitExceed: false,
        noRecents: const Text(
          'No Recents',
          style: TextStyle(fontSize: 20, color: Colors.black26),
          textAlign: TextAlign.center,
        ),
        loadingIndicator: const SizedBox.shrink(),
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const CategoryIcons(),
        buttonMode: ButtonMode.CUPERTINO,
        checkPlatformCompatibility: true,
      ),
    );
    // return EmojiPicker(
    //   textEditingController: widget.textController,
    //   config: Config(
    //     columns: 7,
    //     // Issue: https://github.com/flutter/flutter/issues/28894
    //     // emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
    //     verticalSpacing: 0,
    //     horizontalSpacing: 0,
    //     gridPadding: EdgeInsets.zero,
    //     // initCategory: Category.RECENT,
    //     bgColor: const Color(0xFFF2F2F2),
    //     indicatorColor: Colors.blue,
    //     iconColor: Colors.grey,
    //     iconColorSelected: Colors.blue,
    //     backspaceColor: Colors.blue,
    //     skinToneDialogBgColor: Colors.white,
    //     skinToneIndicatorColor: Colors.grey,
    //     enableSkinTones: true,
    //     showRecentsTab: true,
    //     recentsLimit: 28,
    //     replaceEmojiOnLimitExceed: false,
    //     noRecents: const Text(
    //       'No Recents',
    //       style: TextStyle(fontSize: 20, color: Colors.black26),
    //       textAlign: TextAlign.center,
    //     ),
    //     loadingIndicator: const SizedBox.shrink(),
    //     tabIndicatorAnimDuration: kTabScrollDuration,
    //     categoryIcons: const CategoryIcons(),
    //     buttonMode: ButtonMode.MATERIAL,
    //     checkPlatformCompatibility: true,
    //   ),
    // );
  }
}
