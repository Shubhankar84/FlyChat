class User {
  String uid;
  String name;
  String email;
  String password;
  String mobileNo;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNo,
  });

  // Convert User object to JSON map for saving to Firestore or other storage
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'password': password,
        'mobileNo': mobileNo,
      };

  // Convert JSON map to User object when retrieving data
  static User fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      mobileNo: map['mobileNo'],
    );
  }
}
