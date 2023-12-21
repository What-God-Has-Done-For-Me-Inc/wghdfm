class SearchModel {
  String? type;
  List<UserList>? userList;

  SearchModel({this.type, this.userList});

  SearchModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['user_list'] != null) {
      userList = <UserList>[];
      json['user_list'].forEach((v) {
        userList!.add(new UserList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.userList != null) {
      data['user_list'] = this.userList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserList {
  String? userId;
  String? firstname;
  String? lastname;
  String? email;
  String? gender;
  String? profileImg;

  UserList({this.userId, this.firstname, this.lastname, this.email, this.gender, this.profileImg});

  UserList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    gender = json['gender'];
    profileImg = json['profile_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['profile_img'] = this.profileImg;
    return data;
  }
}
