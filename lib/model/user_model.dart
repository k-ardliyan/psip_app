class UserModel {
  String? uid;
  String? email;
  String? address;
  String? displayName;
  String? gender;
  String? phoneNumber;
  String? photoURL;
  String? role;

  UserModel({
    this.uid,
    this.email,
    this.address,
    this.displayName,
    this.gender,
    this.phoneNumber,
    this.photoURL,
    this.role,
  });

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      address: map['address'],
      gender: map['gender'],
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
      role: map['role'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'address': address,
      'displayName': displayName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
    };
  }
}
