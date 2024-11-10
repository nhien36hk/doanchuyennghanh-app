import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;

  UserModel({
    required this.phone,
    required this.name,
    required this.id,
    required this.email,
    required this.address,
  });

  UserModel.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)['phone'];
    name = (snap.value as dynamic)['name'];
    id = snap.key;
    email = (snap.value as dynamic)['email'];
    address = (snap.value as dynamic)['address'];
  }
}