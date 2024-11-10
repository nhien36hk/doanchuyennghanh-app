import 'package:drivers_android/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

  Future<void> showUserNameDialogAlert(
      BuildContext context, String name) async {
    nameTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameTextEditingController,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "name": nameTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update Name Successfuly \n Reload the app to see the changes");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Error Occured \n $error");
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showPhoneDialogAlert(
      BuildContext context, String name) async {
    phoneTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: phoneTextEditingController,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "phone": phoneTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update Phone Successfuly \n Reload the app to see the changes");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Error Occured \n $error");
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showAddressDialogAlert(
      BuildContext context, String name) async {
    addressTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: addressTextEditingController,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "address": addressTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update Address Successfuly \n Reload the app to see the changes");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Error Occured \n $error");
                });
              },
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Profile Screen',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue, 
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.name}',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showUserNameDialogAlert(
                              context, userModelCurrentInfo!.name!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                 Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.phone}',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showPhoneDialogAlert(
                              context, userModelCurrentInfo!.phone!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.address}',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showAddressDialogAlert(
                              context, userModelCurrentInfo!.address!);
                        },
                        icon: Icon(Icons.edit))
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  '${userModelCurrentInfo!.email}',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
