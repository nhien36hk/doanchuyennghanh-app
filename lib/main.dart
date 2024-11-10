import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/Assistants/assistants_method.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/screens/rate_driver_screen.dart';
import 'package:trippo_app/splashScreen/splash_screen.dart';
import 'package:trippo_app/themeProvider/theme_provider.dart';
import 'package:trippo_app/widgets/pay_fare_amount_dialog.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfor(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String accessToken = '';

  getToken() async {
    var mytoken = await FirebaseMessaging.instance.getToken();
    print(mytoken);
  }

  @override
  void initState() {
    getToken();
    super.initState();
    getAccessToken();
  }

  Future<void> getAccessToken() async {
    try {
      final serviceAccountJson = await rootBundle.loadString(
          'assets/login-register-firebase-d2cd3-firebase-adminsdk-evbn5-c9ff094ad9.json');
  
      final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );

      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = http.Client();
      try {
        final accessCredentials =
            await obtainAccessCredentialsViaServiceAccount(
          accountCredentials,
          scopes,
          client,
        );

        setState(() {
          accessToken = accessCredentials.accessToken.data;
        });

        print('Access Token: $accessToken');
      } catch (e) {
        print('Error obtaining access token: $e');
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error loading service account JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Token Example'),
      ),
      body: Center(
        child: Text('Access Token: $accessToken'),
      ),
    );
  }
}
