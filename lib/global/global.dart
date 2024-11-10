import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:trippo_app/model/direction_detail_info.dart';
import 'package:trippo_app/model/user_model.dart';
import 'package:trippo_app/screens/main_screen.dart';
import 'package:trippo_app/screens/main_tab_screen.dart';
import 'package:trippo_app/screens/profile_screen.dart';
import 'package:trippo_app/screens/trips_history_screen.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

String userDropOffAddress = "";

DirectionDetailInfo? tripDirectionDetailsInfo;

final pages = [
  MainTabScreen(),
  MainScreen(),
  TripsHistoryScreen(),
  ProfileScreen(),
];

String cloudMessagingServerToken = "";
List driversList = [];
String driverCarDetails = '';
String driverName = '';
String driverPhone = '';
String driverRatings = '';

double countRatingStars = 0.0;
String titleStarsRating = '';

// COLORS
const buttonColor = Color.fromARGB(255, 249, 106, 66);
const lightColor = Color.fromARGB(255, 243, 125, 92);

// FIREBASE
var firebaseStorage = FirebaseStorage.instance;



