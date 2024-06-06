class UserModel {
  String? uid;
  String? email;
  String? address;
  String? displayName;
  String? phoneNumber;
  String? photoURL;

  UserModel({
    this.uid,
    this.email,
    this.address,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
  });

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      address: map['address'],
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'address': address,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
    };
  }
}
