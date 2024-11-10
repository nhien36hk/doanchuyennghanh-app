import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:drivers_android/model/direction_detail_info.dart';
import 'package:drivers_android/model/driver_data.dart';
import 'package:drivers_android/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

AudioPlayer audioPlayer = AudioPlayer();

String userDropOffAddress = "";

DirectionDetailInfo? tripDirectionDetailsInfo;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

String? driverVehicleType = '';

// COLORS
const buttonColor = Color.fromARGB(255, 249, 106, 66);
const lightColor = Color.fromARGB(255, 243, 125, 92);

String? titleStarsRating = '';
