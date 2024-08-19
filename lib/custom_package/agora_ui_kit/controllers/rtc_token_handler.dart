import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../agora_uikit.dart';
import 'session_controller.dart';

/// Function to get the RTC token from the server. Follow t
Future<void> getToken({
  String? tokenUrl,
  String? channelName,
  int? uid = 0,
  required SessionController sessionController,
}) async {
  final response = await http
      .get(Uri.parse('$tokenUrl/rtc/$channelName/publisher/uid/$uid'));
  if (response.statusCode == HttpStatus.ok) {
    sessionController.value = sessionController.value
        .copyWith(generatedToken: jsonDecode(response.body)['rtcToken']);
  } else {
    log("${response.reasonPhrase}",
        level: Level.error.value, name: "AgoraVideoUIKit");
    log("Failed to generate the token : ${response.statusCode}",
        level: Level.error.value, name: "AgoraVideoUIKit");
  }
}
