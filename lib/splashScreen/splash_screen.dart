import 'dart:async';

import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/screens/login_screen.dart';
import 'package:drivers_android/screens/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  startTimer() {
    Timer(
      Duration(seconds: 3),
      () async {
        if (await firebaseAuth.currentUser != null) {
          // Chờ cho việc lấy thông tin driver và online user hoàn tất
          await AssistantsMethod.readCurrnetOnlineUserInfo();

          // Sau khi dữ liệu đã được tải, điều hướng đến MainScreen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => MainScreen()));
        } else {
          // Nếu không có người dùng đăng nhập, điều hướng đến LoginScreen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Yêu cầu quyền nhận thông báo trên iOS
    _firebaseMessaging
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    )
        .then((settings) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("Người dùng đã cấp quyền nhận thông báo");
      } else {
        print("Người dùng từ chối nhận thông báo");
      }
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Trippo',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
