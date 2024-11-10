import 'package:audioplayers/audioplayers.dart';
import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/model/user_ride_request_information.dart';
import 'package:drivers_android/screens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  NotificationDialogBox({super.key, this.userRideRequestInformation});

  UserRideRequestInformation? userRideRequestInformation;

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: darkTheme ? Colors.black : Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(onlineDriverData.car_type == "Car"
                ? "images/Car1.png"
                : onlineDriverData.car_type == "CNG"
                    ? "images/CNG.png"
                    : "images/bike.png"),
            SizedBox(
              height: 10,
            ),
            Text(
              "Chuyến thu gom mới",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  fontSize: 22),
            ),
            SizedBox(
              height: 14,
            ),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestInformation!.orginAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                 
                ],
              ),
            ),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            //button for cacelling and accepting the ride request
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AudioPlayer();

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Từ chối".toUpperCase(),
                      style: TextStyle(fontSize: 15),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AudioPlayer();
                           Navigator.pop(context);
                      accepRideRequest(context);
                    },
                    child: Text(
                      "Chấp nhận".toUpperCase(),
                      style: TextStyle(fontSize: 15),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  accepRideRequest(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value == "idle") {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("newRideStatus")
            .set("accepted");
        AssistantsMethod.pauseLiveLocationUpdate();
        if (mounted) {
          // Kiểm tra nếu widget còn tồn tại
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewTripScreen(
                  userRideRequestDetails: widget.userRideRequestInformation,
                ),
              ));
        }
      } else {
        if (mounted) {
          // Kiểm tra nếu widget còn tồn tại
          Fluttertoast.showToast(msg: "This Ride Request Do Not Accepted");
        }
      }
    });
  }
}
