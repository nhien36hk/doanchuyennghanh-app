import 'dart:async';

import 'package:app_intern/constants.dart';
import 'package:app_intern/screens/home_screen.dart';
import 'package:app_intern/screens/welcome_login_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  getPref() async {
    Timer(Duration(seconds: 4), () {
      if (firebaseAuth.currentUser == false) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelComeLoginScreen(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: buttonColor,
      body: Container(
        child: Center(
          child: Column(
            children: [
              Image(
                image: AssetImage("assets/images/logo.jpg"),
              ),
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
