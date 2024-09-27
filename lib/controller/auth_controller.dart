import 'dart:async';

import 'package:app_intern/constants.dart';
import 'package:app_intern/models/user.dart' as model;
import 'package:app_intern/screens/home_screen.dart';
import 'package:app_intern/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Sử dụng Rx<model.User?> thay vì Rx<User?> để phù hợp với lớp model của bạn
  late Rx<model.User?> _user;

  @override
  void onReady() {
    super.onReady();
    // Khởi tạo _user với giá trị null
    _user = Rx<model.User?>(null);
    // Theo dõi sự thay đổi trạng thái đăng nhập
    _user.bindStream(firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        // Lấy thông tin người dùng từ Firestore
        DocumentSnapshot doc = await firestore.collection('users').doc(user.uid).get();
        // Chuyển đổi dữ liệu từ Firestore thành model.User
        return model.User.fromSnap(doc);
      } else {
        return null;
      }
    }));
    // Xử lý khi trạng thái người dùng thay đổi
    ever(_user, _setInitialScreen);
  }

  void _setInitialScreen(model.User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Timer(Duration(seconds: 4), () {
        Get.offAll(() => HomeScreen());
      });
    }
  }

  static AuthController instance = Get.find();

  void changeIndex(int index) {}

  void registerUser(String name, String password, String email) async {
    try {
      if (name.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String uid = cred.user?.uid ?? '';
        model.User user = model.User(
            name: name,
            email: email,
            uid: uid,
            avt: '',
            address: '',
            phone: '',
            role: '0');
        await firestore.collection('users').doc(uid).set(user.toJson());
      } else {
        Get.snackbar('Lỗi tạo tài khoản', 'Bạn cần nhập đầy đủ thông tin');
      }
    } catch (e) {
      Get.snackbar('Lỗi tạo tài khoản', e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        Get.snackbar('Lỗi đăng nhập', 'Vui lòng điền đầy đủ thông tin!');
      }
    } catch (e) {
      Get.snackbar('Lỗi đăng nhập', e.toString());
    }
  }

  void logOut() async {
    await firebaseAuth.signOut();
  }
}
