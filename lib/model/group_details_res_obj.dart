///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class GroupDetailsModelData {
/*
{
  "name": "Cyclone Alert Group Private",
  "group_description": null,
  "group_id": "102",
  "owner_id": "3338",
  "owner_name": "darshil rabadiya ",
  "profilePic": "https://wghdfm.s3.amazonaws.com/thumb/1671083924.jpg",
  "cover_pic": "https://wghdfm.s3.amazonaws.com/medium/1483377260.JPG",
  "created_on": "16 June 2023",
  "type": "P",
  "send_req_button": "N",
  "is_admin": "N",
  "is_active": "P",
  "post_ability": "N"
}
*/

  String? name;
  String? groupDescription;
  String? groupId;
  String? ownerId;
  String? ownerName;
  String? profilePic;
  String? coverPic;
  String? createdOn;
  String? type;
  String? sendReqButton;
  String? isAdmin;
  String? isActive;
  String? postAbility;

  GroupDetailsModelData({
    this.name,
    this.groupDescription,
    this.groupId,
    this.ownerId,
    this.ownerName,
    this.profilePic,
    this.coverPic,
    this.createdOn,
    this.type,
    this.sendReqButton,
    this.isAdmin,
    this.isActive,
    this.postAbility,
  });

  GroupDetailsModelData.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    groupDescription = json['group_description']?.toString();
    groupId = json['group_id']?.toString();
    ownerId = json['owner_id']?.toString();
    ownerName = json['owner_name']?.toString();
    profilePic = json['profilePic']?.toString();
    coverPic = json['cover_pic']?.toString();
    createdOn = json['created_on']?.toString();
    type = json['type']?.toString();
    sendReqButton = json['send_req_button']?.toString();
    isAdmin = json['is_admin']?.toString();
    isActive = json['is_active']?.toString();
    postAbility = json['post_ability']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['group_description'] = groupDescription;
    data['group_id'] = groupId;
    data['owner_id'] = ownerId;
    data['owner_name'] = ownerName;
    data['profilePic'] = profilePic;
    data['cover_pic'] = coverPic;
    data['created_on'] = createdOn;
    data['type'] = type;
    data['send_req_button'] = sendReqButton;
    data['is_admin'] = isAdmin;
    data['is_active'] = isActive;
    data['post_ability'] = postAbility;
    return data;
  }
}

class GroupDetailsModel {
/*
{
  "type": "success",
  "data": {
    "name": "Cyclone Alert Group Private",
    "group_description": null,
    "group_id": "102",
    "owner_id": "3338",
    "owner_name": "darshil rabadiya ",
    "profilePic": "https://wghdfm.s3.amazonaws.com/thumb/1671083924.jpg",
    "cover_pic": "https://wghdfm.s3.amazonaws.com/medium/1483377260.JPG",
    "created_on": "16 June 2023",
    "type": "P",
    "send_req_button": "N",
    "is_admin": "N",
    "is_active": "P",
    "post_ability": "N"
  }
}
*/

  String? type;
  GroupDetailsModelData? data;

  GroupDetailsModel({
    this.type,
    this.data,
  });

  GroupDetailsModel.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    data = (json['data'] != null)
        ? GroupDetailsModelData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    if (data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
