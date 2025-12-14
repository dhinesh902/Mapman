class ProfileData {
  int? id;
  String? userName;
  String? profilePic;
  String? phone;
  String? email;

  ProfileData({
    this.id,
    this.userName,
    this.profilePic,
    this.phone,
    this.email,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    profilePic = json['profilePic'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userName'] = userName;
    data['profilePic'] = profilePic;
    data['phone'] = phone;
    data['email'] = email;
    return data;
  }
}
