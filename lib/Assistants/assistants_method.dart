import 'dart:async';
import 'dart:convert';

import 'package:drivers_android/Assistants/request_assistants.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/global/map_key.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:drivers_android/model/direction.dart';
import 'package:drivers_android/model/direction_detail_info.dart';
import 'package:drivers_android/model/trips_history_model.dart';
import 'package:drivers_android/model/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantsMethod {
  static Future<void> readCurrnetOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestRespone = await RequestAssistants.recalveRequest(apiUrl);

    // Kiểm tra nếu requestRespone trả về null hoặc danh sách trống
    if (requestRespone != "Error Occured. Failed. No Response." &&
        requestRespone["results"] != null &&
        requestRespone["results"].isNotEmpty) {
      humanReadableAddress = requestRespone["results"][0]["formatted_address"];

      Direction userPickUpAddress = Direction();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongtitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;
    } else {
      return "Không tìm thấy địa chỉ.";
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://us1.locationiq.com/v1/directions/driving/${originPosition.longitude},${originPosition.latitude};${destinationPosition.longitude},${destinationPosition.latitude}?key=$locationIQ&steps=true&alternatives=true&geometries=polyline&overview=full&";

    var responseDirectionApi = await RequestAssistants.recalveRequest(
        urlOriginToDestinationDirectionDetails);

    print("Request URL: $urlOriginToDestinationDirectionDetails");

    print("Response from API: $responseDirectionApi");

    if (responseDirectionApi is Map) {
      if (responseDirectionApi["code"] == "Ok" &&
          responseDirectionApi["routes"] != null &&
          responseDirectionApi["routes"].isNotEmpty) {
        // Xử lý dữ liệu từ responseDirectionApi["routes"]
      } else {
        print(
            "Error origin: ${originPosition.toString()}, destination: ${destinationPosition.toString()}");
      }
    } else {
      print("Unexpected response structure: $responseDirectionApi");
    }

    DirectionDetailInfo directionDetailInfo = DirectionDetailInfo();

    // Trích xuất điểm polyline từ response
    var geometry = responseDirectionApi["routes"][0]["geometry"];
    if (geometry is String) {
      directionDetailInfo.e_points = geometry; // Nếu e_points là String
    } else {
      throw Exception("Unexpected geometry type: ${geometry.runtimeType}");
    }

    // Lấy thông tin về khoảng cách và thời gian từ legs
    var legs = responseDirectionApi["routes"][0]["legs"];
    if (legs != null && legs.isNotEmpty) {
      directionDetailInfo.distance_text =
          (legs[0]["distance"] / 1000).toString() + " km";
      directionDetailInfo.distance_value =
          (legs[0]["distance"] as num).toDouble();
      directionDetailInfo.duration_text =
          (legs[0]["duration"] / 60).toString() + " mins";
      directionDetailInfo.duration_value =
          (responseDirectionApi["routes"][0]["duration"] as num).toDouble();
    } else {
      throw Exception("No legs found in the response.");
    }

    return directionDetailInfo;
  }

  static pauseLiveLocationUpdate() {
    streamSubscriptionPosition!.pause();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('activeDrivers')
        .child(currentUser!.uid);

    ref.remove();

    DatabaseReference statusRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid)
        .child("newRideStatus");

    statusRef.onDisconnect();
    statusRef.remove();
  }

  static double calculateFareAmountFromriginTDestination(
      DirectionDetailInfo directionDetailInfo) {
    double timeTravelledFareAmountPerMinute =
        (directionDetailInfo.duration_value! / 60) * 0.1;
    double distanceTravelledFreaAmuntPerKillometer =
        (directionDetailInfo.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravelledFreaAmuntPerKillometer;
    double localCurrencyTotalFare = totalFareAmount + 107;
    if (driverVehicleType == 'Bike') {
      double resultsFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      resultsFareAmount;
    } else if (driverVehicleType == 'CNG') {
      double resultsFareAmount = ((localCurrencyTotalFare.truncate()) * 1.5);
      resultsFareAmount;
    } else if (driverVehicleType == 'Car') {
      double resultsFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
      resultsFareAmount;
    } else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
    return localCurrencyTotalFare.truncate().toDouble();
  }

  //Retrieve the trips keys for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineDriver(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(firebaseAuth.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfor>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);
        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfor>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);
        //get trips keys data = read trips complete information
        readTripsHistoryInforMation(context);
      }
    });
  }

  static Future<void> readCurrenDriverInformation(context) async {
    try {
      currentUser = firebaseAuth.currentUser;
      final snap = await FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser!.uid)
          .once();

      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)['id'];
        onlineDriverData.name = (snap.snapshot.value as Map)['name'];
        onlineDriverData.phone = (snap.snapshot.value as Map)['phone'];
        onlineDriverData.email = (snap.snapshot.value as Map)['email'];
        onlineDriverData.address = (snap.snapshot.value as Map)['address'];
        onlineDriverData.ratings = (snap.snapshot.value as Map)['ratings'];
        onlineDriverData.car_color =
            (snap.snapshot.value as Map)['car_details']['car_color'];
        onlineDriverData.car_model =
            (snap.snapshot.value as Map)['car_details']['car_model'];
        onlineDriverData.car_number =
            (snap.snapshot.value as Map)['car_details']['car_number'];
        onlineDriverData.car_type =
            (snap.snapshot.value as Map)['car_details']['type'];

        driverVehicleType = (snap.snapshot.value as Map)['car_details']['type'];

        print("Dữ liệu của driver: ${onlineDriverData.toString()}");
      } else {
        print("Không tìm thấy dữ liệu cho người dùng này");
      }
    } catch (e) {
      print("Lỗi khi đọc dữ liệu: $e");
    }

    AssistantsMethod.readDriverEarnings(context);
  }

  static void readTripsHistoryInforMation(context) {
    var tripsAllKeys =
        Provider.of<AppInfor>(context, listen: false).historyTripsKeysList;
    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then(
        (snap) {
          var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
          if ((snap.snapshot.value as Map)['status'] == "ended") {
            String driverEarnings = (snap.snapshot.value as Map)['fareAmount'];

            Provider.of<AppInfor>(context, listen: false)
                .updateDriverTotalEarnings(driverEarnings);
            Provider.of<AppInfor>(context, listen: false)
                .updateOverAllTripsHistoryInformation(eachTripHistory);
          }
        },
      );
    }
  }

  static void readDriverEarnings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid!)
        .child('earnings')
        .once()
        .then(
      (snap) {
        if (snap.snapshot.value != null) {
          String driverEarning = snap.snapshot.value.toString();
          Provider.of<AppInfor>(context, listen: false)
              .updateDriverTotalEarnings(driverEarning);
        }
      },
    );
    readTripsKeysForOnlineDriver(context);
  }

  static Future<void> readDriverRatings(context) async {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid!)
        .child('ratings')
        .once()
        .then(
      (snap) {
        if (snap.snapshot.value != null) {
          String driverEarning = snap.snapshot.value.toString();
          print("đã đếm ratings yes" + driverEarning);
          Provider.of<AppInfor>(context, listen: false)
              .updateDriverAverageRatings(driverEarning);
        }
      },
    );
  }
}
