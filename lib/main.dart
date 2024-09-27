import 'package:app_intern/controller/auth_controller.dart';
import 'package:app_intern/screens/home_screen.dart';
import 'package:app_intern/screens/welcome_login_screen.dart';
import 'package:app_intern/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) => {
    Get.put(AuthController())
  });
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      ),
      getPages: [
        GetPage(name: '/home', page:() =>  WelcomeScreen()),
      ],
      home: WelcomeScreen(),
    );
  }
}