import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/Assistants/request_assistants.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/global/map_key.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/direction.dart';
import 'package:trippo_app/model/direction_detail_info.dart';
import 'package:trippo_app/model/trips_history_model.dart';
import 'package:trippo_app/model/user_model.dart';
import 'package:http/http.dart' as http;

class AssistantsMethod {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String accessToken = "";
  static String userRideRequestid = "";
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
        accessToken = accessCredentials.accessToken.data;

        print('Access Token1: $accessToken');
      } catch (e) {
        print('Error obtaining access token: $e');
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error loading service account JSON: $e');
    }
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

    print("responseDirectionApi: $responseDirectionApi");

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

  static double calculateFareAmountFromOrigintoDestination(
      DirectionDetailInfo directionDetailInfo) {
    double timeTravelledFareAmountPerMinute =
        (directionDetailInfo.duration_value! / 60) * 1000;
    double distanceTravalledFareAmountPerKilometer =
        (directionDetailInfo.distance_value! / 1000 * 6000);

    //USD
    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravalledFareAmountPerKilometer;
    return double.parse(totalFareAmount.toStringAsFixed(0));
  }

  static String formatCurrency(double amount) {
    final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");
    return currencyFormat.format(amount);
  }

  static sendNotificationToDriverNow(String oneSignalUserId,
      String ueRideRequestId, String destinationAddress) async {
    if (oneSignalUserId.isEmpty) {
      print("OneSignal User ID is empty.");
      return; // Không gửi thông báo nếu user ID không hợp lệ
    }

    print("OneSignal avs" + oneSignalUserId);

    // Cấu hình tiêu đề và nội dung thông báo
    Map<String, dynamic> bodyNotification = {
      "app_id": oneSignal,
      "include_player_ids": [oneSignalUserId],
      "headings": {"en": "New Trip Request"},
      "contents": {"en": "Destination Address: \n $destinationAddress."},
      "data": {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "status": "done",
        "rideRequestId": ueRideRequestId,
      },
    };

    // Gửi yêu cầu POST đến OneSignal API
    var responseNotification = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Basic MmI1Mzk3ZGUtOTc1Yi00MGNhLTkwMjgtYzc5YmZkYWMxODIw",
      },
      body: jsonEncode(bodyNotification),
    );

    // Kiểm tra phản hồi
    if (responseNotification.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print(
          "Failed to send notification: ${responseNotification.statusCode} - ${responseNotification.body}");
    }
  }

  Future<void> generateAndGetToken() async {
    await messaging.deleteToken();
    String? registrationToken = await messaging.getToken();
    print("FCM registration TOKEN: $registrationToken");
  }

  //Trip key = ride request key
  static Future<void> readTripsKeyForOnlineUser(context) async {
    print("Vao roi ma idUser${userModelCurrentInfo!.name!}");
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripId = snap.snapshot.value as Map;

        //count total number of trips and share it with Provider
        int overAllTripsCounter = keysTripId.length;
        Provider.of<AppInfor>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with provider
        List<String> tripsKeysList = [];
        keysTripId.forEach((key, value) {
          tripsKeysList.add(key);
        });

        Provider.of<AppInfor>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);

        //get trips key data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys =
        Provider.of<AppInfor>(context, listen: false).historyTripsKeysList;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)['status'] == "ended") {
          //update or add each history to OverAllTrips History data list
          Provider.of<AppInfor>(context, listen: false)
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }
}
