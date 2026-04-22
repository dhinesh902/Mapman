class ProfileData {
  int? id;
  String? userName;
  String? profilePic;
  String? phone;
  String? email;
  String? state;
  String? district;
  String? country;

  ProfileData({
    this.id,
    this.userName,
    this.profilePic,
    this.phone,
    this.email,
    this.state,
    this.district,
    this.country,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    profilePic = json['profilePic'];
    phone = json['phone'];
    email = json['email'];
    state = json['state'];
    district = json['district'];
    country = json['country'];
  }
}
