import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtm/agora_rtm.dart';
import '../agora_uikit.dart';
import '../models/rtm_message.dart';
import 'rtm_controller_helper.dart';
import 'rtm_token_handler.dart';
import 'session_controller.dart';

Future<void> rtmClientEventHandler({
  required AgoraRtmClient agoraRtmClient,
  required AgoraRtmClientEventHandler agoraRtmClientEventHandler,
  required SessionController sessionController,
}) async {
  const String tag = "AgoraVideoUIKit";

  agoraRtmClient.onMessageReceived = (RtmMessage message, String peerId) {
    agoraRtmClientEventHandler.onMessageReceived?.call(message, peerId);
    Message msg = Message(text: message.text);
    String? messageType;

    final body = json.decode(message.text);
    messageType = body['messageType'];

    messageReceived(
      messageType: messageType!,
      message: msg.toJson(),
      sessionController: sessionController,
    );
  };

  agoraRtmClient.onConnectionStateChanged2 = (state, reason) {
    agoraRtmClientEventHandler.onConnectionStateChanged2?.call(state, reason);

    log(
      'Connection state changed : ${state.toString()}, reason : ${reason.toString()}',
      level: Level.info.value,
      name: tag,
    );
    if (state == RtmConnectionState.aborted) {
      agoraRtmClient.logout();
    }
  };

  agoraRtmClient.onError = (error) {
    agoraRtmClientEventHandler.onError?.call(error);

    log(
      'Error Occurred while initializing the RTM client: ${error.hashCode}',
      level: Level.error.value,
      name: tag,
    );
  };

  agoraRtmClient.onTokenExpired = () {
    agoraRtmClientEventHandler.onTokenExpired?.call();

    getRtmToken(
      tokenUrl: sessionController.value.connectionData!.tokenUrl,
      sessionController: sessionController,
    );
  };

  agoraRtmClient.onPeersOnlineStatusChanged = (peersStatus) {
    agoraRtmClientEventHandler.onPeersOnlineStatusChanged?.call(peersStatus);
  };

  agoraRtmClient.onTokenPrivilegeWillExpire = () {
    agoraRtmClientEventHandler.onTokenPrivilegeWillExpire?.call();
  };
}
