class EndPoints {
  static const String baseUrl = "https://whatgodhasdoneforme.com/mobile/";
  static const String webUrl = "https://whatgodhasdoneforme.com/";

  static String VIDEO_URL = "https://s3.amazonaws.com/wghdfm/videowires/";
  static String VIDEO_THUMB_URL = "https://wghdfm.s3.amazonaws.com/thumbnails/";

  // end Points
  static const String signUpApi = "signup"; //done
  static const String signInApi = "login"; //done
  static const String registrationApi = "signup/send_reg_otp"; //done
  static const String completeRegisterUserApi =
      "signup/complete_register_user"; //done
  static const String editPost = "wire/only_wirepost/"; //done
  static const String deletePostApi = "wire/delete_post/"; //done
  static const String addFavApi = "wire/add_favorite/"; //done
  static const String unFavApi = "wire/remove_favorite/"; //done
  static const String likeUserApi = "wire/like_users/"; //done
  static const String insertLikeApi = "wire/insert_likes/";
  static const String addTimeLineApi = "wire/add_share/"; //done
  static const String addMessageApi = "wire/add_message"; //done

  static const String socialSharePostUrl =
      "https://whatgodhasdoneforme.com/profile/post/index/";
  static const String postUploadingURL =
      "https://api.whatgodhasdoneforme.com/users/postUploaded";
  static const String addReportData = "wire/report_post/";
  static const String userDetails = "wire/user_details/";
  static const String userUnBloc = "user/unblock";
  static const String userBloc = "user/block";
  static const String changePassword = "user/change_password";
  static const String deleteProfile = "user/delete_profile";
  static const String inviteFriends = "user/invite";
  static const String getUnreadMsgCount = "user/unread_msg_count";
  static const String getAllMessages = "user/get_all_messages";
  static const String donate = "donate/donate_success";

  static String uploadVideoUrl = "wire/video_post/";
  static String getAllGrpURL = "wire/get_all_groups/";
  static String shareToGrpURL = "wire/share_from_timeline_to_group";
  static String friendsListAPI = "wire/get_friend_list";

  static String uploadOriginalImgUrl =
      "wire/multi_media_post"; //status code 200 RESPONSE DATA : {"type":"error","message":"Invalid User!"}
  static String uploadPostData =
      "wire/upload_post_data"; //status code 200 RESPONSE DATA : {"type":"error","message":"Invalid User!"}
  static String uploadImageInGrp =
      "wire/multi_media_group_post"; //status code 200 RESPONSE DATA : {"type":"error","message":"Invalid User!"}
  static String uploadLinkStatusInGrp =
      "wire/only_group_wirepost"; //status code 200 RESPONSE DATA : {"type":"error","message":"Invalid User!"}
  static String addFeedStatusUrl =
      "wire/wire_post/"; //status code = 200,====================>DioError [DioErrorType.response]: Http status error [500]
  static String addFeedStatusInGroupUrl =
      "wire/only_group_wirepost/"; //status code = 200,====================>DioError [DioErrorType.response]: Http status error [500]
  static String forgetPasswordUrl = "login/forgetpassword";
  static String viewForgetPassUrl = "user/view_forgot_pass";
  static String loadFriendsUrl =
      "wire/friend/"; //status code 200  API RESPONSE DATA : null
  static String favUrl = "wire/favorites/";

  static String commentUrl = "comment/get_comment";
  static String commentUrlForGrp = "wire/get_comments";

  static String deleteCommentUrl = "comment/delete_comment";
  static String deleteGrpCommentUrl = "wire/delete_comment";
  static String updateProfileImage = "user/update_profile_image";
  static String searchUser = "user/search_user";
  static String updateCoverImage = "user/update_cover_image";

  static String selectedPostId = '0';
  static String ImageURl = 'https://wghdfm.s3.amazonaws.com/thumb/';
  static String insertCommentUrl =
      "comment/insert_comment"; //API STATUS CODE : 200 RESPONSE DATA : {"type":"error","message":"something went wrong!"}
  static String insertCommentForGrpUrl = "wire/insert_comment";
}
