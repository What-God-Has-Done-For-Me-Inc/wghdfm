import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:read_more_text/read_more_text.dart';
// import 'package:readmore/readmore.dart';
import 'package:wghdfm_java/services/open_in_web_service.dart';

getLinkText({required String text}) {
  return ReadMoreText.selectable(
    text,
    numLines: 3,
    readLessText: '  Read less',
    readMoreText: 'Read more',
    readMoreIcon: const SizedBox(),
    readLessIcon: const SizedBox(),
    readMoreTextStyle:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    locale: const Locale('en'),
    toolbarOptions: const ToolbarOptions(
      copy: true,
      selectAll: true,
    ),
    showCursor: false,
  );
  // return ReadMoreText(
  //   text,
  //   trimLines: 3,
  //   colorClickableText: Colors.pink,
  //   trimMode: TrimMode.Line,
  //   trimCollapsedText: 'Read more',
  //   trimExpandedText: '  Read less',
  //   lessStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //   moreStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  // );
}

List<TextSpan> getTextSpan({required String textWithLink}) {
  List<TextSpan> textSpans = [];
  int startIndex = 0;
  for (Match match in validateLink.allMatches(textWithLink)) {
    if (match.start > startIndex) {
      textSpans.add(TextSpan(
        text: textWithLink.substring(startIndex, match.start),
        style: TextStyle(
          color: Colors.black45,
          fontSize: 15.0,
          height: 1.8,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
      ));
    }
    String linkText = match.group(0)!;
    textSpans.add(TextSpan(
      text: linkText,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          print(" Link is $linkText");
          openInBrowser(url: linkText);
          // openInWeb(linkText);
          // Handle link tap here
        },
    ));

    startIndex = match.end;
  }

  if (startIndex < textWithLink.length) {
    textSpans.add(TextSpan(
      text: textWithLink.substring(startIndex),
      style: TextStyle(
        color: Colors.black45,
        fontSize: 15.0,
        height: 1.8,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      ),
    ));
  }

  return textSpans;
}

RegExp validateLink = RegExp(
  r"(http(s)?:\/\/[^\s]+)",
  caseSensitive: false,
  multiLine: false,
);
