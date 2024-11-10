import 'package:audioplayers/audioplayers.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/model/user_ride_request_information.dart';
import 'package:drivers_android/pushNotification/notification_dialog_box.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  // Khởi tạo FirebaseMessaging
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1. Teminated
    //Xử lý khi ứng dụng ở trạng thái đóng và người dùng mở ứng dụng từ thông báoo
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestinformation(
            remoteMessage.data['rideRequestId'], context);
      }
    });

    //2. Foreground
    //: Khi ứng dụng đang hoạt động và nhận được thông báo mới
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      readUserRideRequestinformation(
          remoteMessage.data['rideRequestId'], context);
    });

    //3. Background
    //Được gọi khi ứng dụng đang chạy ngầm và người dùng mở ứng dụng thông qua thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestinformation(
          remoteMessage!.data['rideRequestId'], context);
    });
  }

  readUserRideRequestinformation(
      String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .child("driverId")
        .onValue
        .listen((events) {
      if (events.snapshot.value == "waiting" ||
          events.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(userRideRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            // Mở file âm thanh
            audioPlayer.setSource(AssetSource('music/music_notification.mp3'));
            // Phát âm thanh
            audioPlayer.resume();

            double originLat = double.parse(
                (snapData.snapshot.value! as Map)['origin']['latitude']);
            double originLng = double.parse(
                (snapData.snapshot.value! as Map)['origin']['longtitude']);
            String originAddress =
                (snapData.snapshot.value! as Map)['originAddress'];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails =
                UserRideRequestInformation();
            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.orginAddress = originAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;
            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(
                      userRideRequestInformation: userRideRequestDetails,
                    ));
          } else {
            Fluttertoast.showToast(msg: 'This Ride Request Id do not exists.');
          }
        });
      } else {
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled");
        Navigator.pop(context);
      }
    });
  }

  Future<void> generateAndGetToken() async {
    try {
      // Lấy token hiện tại từ Firebase Messaging
      String? registrationToken = await messaging.getToken();
      print("Token hien tai: "+ registrationToken.toString());
      if (registrationToken != null) {
        await _saveTokenToDatabase(registrationToken);
      } else {
        print("Failed to obtain FCM registration token.");
      }

      // Đăng ký lắng nghe sự kiện khi token được làm mới
      messaging.onTokenRefresh.listen((newToken) async {
        print("New FCM registration TOKEN: $newToken");
        await _saveTokenToDatabase(newToken);
      });
    } catch (e) {
      print("Error generating token: $e");
    }
  }

// Lưu token vào cơ sở dữ liệu nếu có thay đổi
  Future<void> _saveTokenToDatabase(String token) async {
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("token");

    String? currentToken = await tokenRef.get().then((snapshot) {
      return snapshot.value as String?;
    });

    // Nếu token mới khác với token đã lưu, cập nhật cơ sở dữ liệu
    if (currentToken != token) {
      await tokenRef.set(token);
      print("Token updated in the database.");
    } else {
      print("Token is already up-to-date.");
    }
  }
}
