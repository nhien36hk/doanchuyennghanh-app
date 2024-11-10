import 'dart:async';

import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  late Future<void> _driverDataFuture;

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void> showUserNameDialogAlert(
      BuildContext context, String name) async {
    nameTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
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
                'Hủy bỏ',
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
                          "Cập nhật thành công \n Vui lòng tải lại app");
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Lỗi \n $error");
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

  Future<void> showPhoneDialogAlert(BuildContext context, String name) async {
    phoneTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
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
                'Hủy bỏ',
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
                          "Cập nhật thành công \n Vui lòng tải lại app");
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

  Future<void> showAddressDialogAlert(BuildContext context, String name) async {
    addressTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật"),
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
                'Hủy bỏ',
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
                          "Cập nhật thành công \n Vui lòng tải lại app");
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
  void initState() {
    // TODO: implement initState
    super.initState();
  
    
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (onlineDriverData == null) {
      return Center(child: CircularProgressIndicator());
    }
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
              color: darkTheme ? Colors.amber.shade400 : Colors.black,
            ),
          ),
          title: Text(
            "Trang cá nhân",
            style: TextStyle(
              color: darkTheme ? Colors.amber.shade400 : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                          color: darkTheme
                              ? Colors.amber.shade400
                              : buttonColor,
                          shape: BoxShape.circle),
                      child: Icon(
                        Icons.person,
                        color: darkTheme ? Colors.black : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${onlineDriverData!.name}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black),
                        ),
                        IconButton(
                            onPressed: () {
                              showUserNameDialogAlert(
                                  context, onlineDriverData!.name!);
                            },
                            icon: Icon(Icons.edit,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.black))
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${onlineDriverData!.phone}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black),
                        ),
                        IconButton(
                            onPressed: () {
                              showPhoneDialogAlert(
                                  context, onlineDriverData!.phone!);
                            },
                            icon: Icon(Icons.edit,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.black))
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${onlineDriverData!.address}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black),
                        ),
                        IconButton(
                            onPressed: () {
                              showAddressDialogAlert(
                                  context, onlineDriverData!.address!);
                            },
                            icon: Icon(Icons.edit,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.black))
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Text(
                      "${onlineDriverData.email}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              darkTheme ? Colors.amber.shade400 : Colors.black),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${onlineDriverData.car_model} \n${onlineDriverData.car_color} (${onlineDriverData.car_number})',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black),
                        ),
                        Image.asset(onlineDriverData.car_type == "Car"
                            ? 'images/Car1.png'
                            : onlineDriverData.car_type == "Bike"
                                ? 'images/bike.png'
                                : 'images/delivery.png', scale: 2,),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        firebaseAuth.signOut();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ));
                      },
                      child: Text(
                        "Đăng xuất",
                        style: TextStyle(
                          color: darkTheme ? Colors.black : Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
