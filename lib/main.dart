import 'dart:io';

import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:drivers_android/screens/car_info_screen.dart';
import 'package:drivers_android/screens/login_screen.dart';
import 'package:drivers_android/splashScreen/splash_screen.dart';
import 'package:drivers_android/themeProvider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAc9wEDFTqWyZd4ZwauYD3aGYqM-8l7eeU",
      appId: "1:744521823113:android:87637397128e97dba0e758",
      messagingSenderId: "744521823113",
      projectId: "login-register-firebase-d2cd3",
    ),
  );

  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfor(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: SplashScreen(),
      ),
    );
  }
}
