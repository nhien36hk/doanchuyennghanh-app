import 'dart:async';
import 'dart:convert';

import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:drivers_android/model/direction.dart';
import 'package:drivers_android/pushNotification/push_notification_system.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;
  String? _address;

  Future<void> checkLocationPermission() async {
    //Check trước đó người dùng đã từ chối chưa
    LocationPermission permission = await Geolocator.checkPermission();

    //Nếu từ chối rồi ta xin lại quyền
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission permissionResult =
          await Geolocator.requestPermission();

      if (permissionResult == LocationPermission.denied) {
        throw Exception("Quyền vị trí đã bị từ chối");
      }
      if (permissionResult == LocationPermission.deniedForever) {
        throw Exception(
            "Quyền vị trí đã bị từ chối vĩnh viễn. Vui lòng bật lại từ cài đặt.");
      }
    }
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
    final apiKey =
        '4572ef7da7484316b104dc8cb9e317f7'; // Thay thế bằng API key của bạn
    final url =
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Trả về chuỗi json biến nó thành đối tượng để sử dụng trong dart
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final address =
              data['results'][0]['formatted']; // Địa chỉ được định dạng
          final components = data['results'][0]['components'];

          // Lấy số nhà nếu có
          final houseNumber = components['house_number'] ?? 'Không có số nhà';

          print('Số nhà: $houseNumber'); // In số nhà ra console
          print('Địa chỉ: $address');

          setState(() {
            _address = '$houseNumber, $address';
            Direction userPickUpAddress = Direction();
            userPickUpAddress.locationLongtitude = longitude;
            userPickUpAddress.locationLatitude = latitude;
            userPickUpAddress.locationName = address; // Dùng _address

            // Cập nhật địa chỉ pick up
            Provider.of<AppInfor>(context, listen: false)
                .updatePickUpLocationAddress(userPickUpAddress);
          });
        } else {
          print('Không tìm thấy địa chỉ cho tọa độ này.');
        }
      } else {
        print('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi trong getAddressFromLatLng: $e');
    }
  }

  Future<void> locationDriverPosition() async {
    try {
      await checkLocationPermission();
      //Sử dụng Position của Geolocator để lấy vị trí hiện tại còn muốn tương tác với CAMERAPOSITION phải chuyển sang LatLng
      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      driverCurrentPosition = cPosition;

      LatLng latLngPosition = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 15);

      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // Gọi hàm getAddressFromLatLng để lấy địa chỉ
      await getAddressFromLatLng(
          latLngPosition.latitude, latLngPosition.longitude);

      // initializeGeoFireListener();
      // AssistantsMethod.readTripsKeysForOnlineUser(context);
      await AssistantsMethod.readCurrenDriverInformation(context);
      AssistantsMethod.readDriverRatings(context);
    } catch (e) {
      print("Lỗi lấy vị trí người dùng: $e");
    }
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    driverCurrentPosition = pos;

    // Thay thế việc lưu vị trí với GeoFire bằng cách lưu trực tiếp vào Firebase
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("activeDrivers")
        .child(currentUser!.uid);

    Map<String, dynamic> driverLocationData = {
      'latitude': driverCurrentPosition!.latitude,
      'longitude': driverCurrentPosition!.longitude,
    };

    ref.set(driverLocationData);

    // Cập nhật trạng thái tài xế
    DatabaseReference statusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");

    statusRef.set("idle");
    statusRef.onValue.listen((event) {});
  }

  updateDriverLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen(
      (Position position) {
        if (isDriverActive == true) {
          //Hàm getPositionStream sẽ lắng nghe vị trí liên tục chính vì vậy phải có điều kiện mặc dù ta đã offline nhưng ta di chuyển thì nó vẫn gọi
          // Lưu vị trí vào Firebase
          DatabaseReference ref = FirebaseDatabase.instance
              .ref()
              .child("activeDrivers")
              .child(currentUser!.uid);

          Map<String, dynamic> driverLocationData = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };

          ref.set(driverLocationData);
        }

        LatLng latLng = LatLng(position.latitude, position.longitude);

        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      },
    );
  }

  driverIsOfflineNow() {
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

    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantsMethod.readCurrenDriverInformation(context);

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controler) {
            if (!_controllerGoogleMap.isCompleted) {
              _controllerGoogleMap.complete(controler);
            }
            newGoogleMapController = controler;
            locationDriverPosition();
          },
        ),
        //ui offline // online
        statusText != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),
        //Button for change status
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isDriverActive != true) {
                    driverIsOnlineNow();
                    updateDriverLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      buttonColor = const Color.fromARGB(0, 206, 149, 149);
                    });
                  } else {
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: "You are offline now");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26))),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    : Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
