import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  String uid;
  String avt;
  String address;
  String phone;
  String role;

  User({
    required this.name,
    required this.email,
    required this.uid,
    required this.avt,
    required this.address,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'uid': uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapShot = snap.data()! as Map<String, dynamic>;
    return User(
      name: snapShot['name'],
      email: snapShot['email'],
      uid: snapShot['uid'],
      avt: snapShot['avt'],
      address: snapShot['address'],
      phone: snapShot['phone'],
      role: snapShot['role'],
    );
  }
}
