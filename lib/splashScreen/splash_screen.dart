import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trippo_app/Assistants/assistants_method.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/screens/home_screen.dart';
import 'package:trippo_app/screens/login_screen.dart';
import 'package:trippo_app/screens/main_screen.dart';
import 'package:trippo_app/screens/main_tab_screen.dart';
import 'package:trippo_app/screens/welcome_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer() {
    Timer(
      Duration(seconds: 3),
      () async {
        if (await firebaseAuth.currentUser != null){
          firebaseAuth.currentUser != null ? await AssistantsMethod.readCurrnetOnlineUserInfo() : null;
          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => WelComeLoginScreen(),));
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonColor,
      body: Container(
        child: Center(
          child: Column(
            children: [
              Image.asset('images/logo.jpg'),
              Text(
                'HUB APP',
                style: TextStyle(
                    fontFamily: 'Phosphate', color: Colors.white, fontSize: 40),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
