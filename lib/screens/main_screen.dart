import 'dart:async';
import 'dart:core';
import 'dart:convert'; // Thư viện để sử dụng JSON
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http; // Thư viện để thực hiện yêu cầu HTTP

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/Assistants/assistants_method.dart';
import 'package:trippo_app/Assistants/geofire_assistant.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/global/map_key.dart';
import 'package:trippo_app/model/active_nearby_available_drivers.dart';
import 'package:trippo_app/screens/precise_pickup_location.dart';
import 'package:trippo_app/screens/rate_driver_screen.dart';
import 'package:trippo_app/screens/search_places_screen.dart';
import 'package:trippo_app/splashScreen/splash_screen.dart';
import 'package:trippo_app/themeProvider/theme_provider.dart'; // Đường dẫn chính xác tới file của bạn
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/direction.dart';
import 'package:trippo_app/widgets/drawer_screen.dart';
import 'package:trippo_app/widgets/order_dialog_widget.dart';
import 'package:trippo_app/widgets/pay_fare_amount_dialog.dart';
import 'package:trippo_app/widgets/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "Could not launch $url";
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double watingResponefromDriverContainerheight = 0;
  double assingedDriverInfoContainerHeight = 0;
  double showSuggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordiatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "";
  String userEmail = "";
  String accessToken = '';

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeyLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String selectedVehicleType = "";

  String driverRideStatus = "Drivers is comming";
  StreamSubscription<DatabaseEvent>? tripDirectionDetailsInfoStreamSubscription;
  String userRideRequestStatus = "";

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  bool requestPositionInfo = true;

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

  Future<void> locationUserPosition() async {
    try {
      await checkLocationPermission();
      //Sử dụng Position của Geolocator để lấy vị trí hiện tại còn muốn tương tác với CAMERAPOSITION phải chuyển sang LatLng
      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition = cPosition;

      LatLng latLngPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 15);

      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // Gọi hàm getAddressFromLatLng để lấy địa chỉ
      await getAddressFromLatLng(
          latLngPosition.latitude, latLngPosition.longitude);

      userName = userModelCurrentInfo!.name!;
      userEmail = userModelCurrentInfo!.email!;

      initializeDriverListener();
      AssistantsMethod.readCurrnetOnlineUserInfo();
    } catch (e) {
      print("Lỗi lấy vị trí người dùng: $e");
    }
  }

  double MAX_DISTANCE_KM = 10.0; // Khoảng cách tối đa là 10 km

  void initializeDriverListener() {
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("activeDrivers");

    driverRef.onChildAdded.listen((event) {
      var snapshot = event.snapshot;
      var driverData = snapshot.value as Map<dynamic, dynamic>;
      String driverId = snapshot.key!;

      // Lấy tọa độ của tài xế
      double driverLatitude = driverData['latitude'];
      double driverLongitude = driverData['longitude'];

      // Tính khoảng cách giữa người dùng và tài xế
      double distance = calculateDistance(userCurrentPosition!.latitude,
          userCurrentPosition!.longitude, driverLatitude, driverLongitude);

      // Kiểm tra xem tài xế có nằm trong khoảng cách cho phép không
      if (distance <= MAX_DISTANCE_KM) {
        //Tạo đối tượng tài xế và lưu những thứ cần thiết vào đối tượng này
        ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
            ActiveNearbyAvailableDrivers(
          driverId: driverId,
          locationLatitude: driverLatitude,
          locationLongtitude: driverLongitude,
        );
        GeofireAssistant.activeNearbyAvailableDriversList.add(
            activeNearbyAvailableDrivers); //Thêm đối tượng này vào đối tượng này vào danh sách tài xế ở gần
        displayActiveDriversOnUserMap();
      }
    });

    driverRef.onChildRemoved.listen((event) {
      String driverId = event.snapshot.key!;
      GeofireAssistant.deleteOffineDriverfromList(driverId);
      displayActiveDriversOnUserMap();
    });

    driverRef.onChildChanged.listen((event) {
      var snapshot = event.snapshot;
      var driverData = snapshot.value as Map<dynamic, dynamic>;
      double driverLatitude = driverData['latitude'];
      double driverLongitude = driverData['longitude'];

      ActiveNearbyAvailableDrivers updatedDriver = ActiveNearbyAvailableDrivers(
        driverId: snapshot.key!,
        locationLatitude: driverLatitude,
        locationLongtitude: driverLongitude,
      );

      // Kiểm tra khoảng cách trước khi cập nhật
      double distance = calculateDistance(userCurrentPosition!.latitude,
          userCurrentPosition!.longitude, driverLatitude, driverLongitude);
      if (distance <= MAX_DISTANCE_KM) {
        GeofireAssistant.updateActiveNearbyAvailableDriverLocation(
            updatedDriver);
      } else {
        GeofireAssistant.deleteOffineDriverfromList(updatedDriver
            .driverId!); // Nếu tài xế ra ngoài khoảng cách, xóa khỏi danh sách
      }

      displayActiveDriversOnUserMap();
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Sử dụng latlong.LatLng để gọi lớp LatLng từ thư viện latlong2
    var distanceInMeters = latlong.Distance().as(latlong.LengthUnit.Meter,
        latlong.LatLng(lat1, lon1), latlong.LatLng(lat2, lon2));
    return distanceInMeters / 1000; // Chuyển đổi từ mét sang km
  }

  void displayActiveDriversOnUserMap() {
    setState(() {
      markersSet.clear();
      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers eachDriver
          in GeofireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(
            eachDriver.locationLatitude!, eachDriver.locationLongtitude!);
        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
          anchor: Offset(0.5, 0.5),
        );

        driversMarkerSet.add(marker);
      }

      markersSet = driversMarkerSet;
    });
  }

  Future<BitmapDescriptor> createResizedBitmapDescriptor(String assetPath,
      {int width = 100, int height = 100}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Nén và thay đổi kích thước hình ảnh
    final Uint8List compressedImage =
        await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: width,
      minHeight: height,
      quality: 100,
      format: CompressFormat.png,
    );

    return BitmapDescriptor.fromBytes(compressedImage);
  }

  void createActiveNearByDriverIconMarker() async {
    if (activeNearbyIcon == null) {
      activeNearbyIcon = await createResizedBitmapDescriptor('images/car.png',
          width: 150, height: 150);
    }
  }

  void showSearchingForDriverContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  void showSuggestedRidesContainer() {
    setState(() {
      showSuggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfor>(context, listen: false).driverLocation;
    var destinationPosition =
        Provider.of<AppInfor>(context, listen: false).userPickUpLocation;

    if (originPosition == null || destinationPosition == null) {
      print('Origin or destination position is null');
      return; // Kết thúc nếu một trong hai vị trí là null.
    }

    if (originPosition == null || destinationPosition == null) {
      print('Origin or destination position is null');
      return; // Nếu một trong hai vị trí là null, hàm sẽ thoát mà không thực hiện thêm.
    }

    if (destinationPosition.locationLatitude == null ||
        destinationPosition.locationLongtitude == null) {
      print('Destination latitude or longitude is null');
      return; // Kết thúc nếu một trong hai thuộc tính là null.
    }

    var originLatLng = LatLng(
        originPosition.locationLatitude!, originPosition.locationLongtitude!);
    var destinationLatLng = LatLng(destinationPosition.locationLatitude!,
        destinationPosition.locationLongtitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Vui lòng đợi...",
            ));

    Navigator.pop(context);

    var directionDetailsInfo =
        await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordiatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordiatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : buttonColor,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordiatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: "Origin",
      ),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarket = Marker(
      markerId: MarkerId("destinationMarket"),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: "Destination",
      ),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarket);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId("originId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  Future<void> loadTripsHistory() async {
    await AssistantsMethod.readCurrnetOnlineUserInfo();
    await AssistantsMethod.readTripsKeyForOnlineUser(context);
  }

  saveRideRequestInformation(String selectedVehicleType) {
    //1. save the rideRequest information
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child('All Ride Requests').push();
    var originLocation =
        Provider.of<AppInfor>(context, listen: false).userPickUpLocation;

    Map originLocationMap = {
      //key and value
      "latitude": originLocation!.locationLatitude.toString(),
      "longtitude": originLocation.locationLongtitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      'time': DateTime.now().toString(),
      'userName': userModelCurrentInfo!.name,
      'userPhone': userModelCurrentInfo!.phone,
      'originAddress': originLocation.locationName,
      'driverId': "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripDirectionDetailsInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)['car_details'] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['driverphone'] != null) {
        setState(() {
          driverPhone =
              (eventSnap.snapshot.value as Map)["driverphone"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['drivername'] != null) {
        setState(() {
          driverName =
              (eventSnap.snapshot.value as Map)["drivername"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['ratings'] != null) {
        setState(() {
          driverRatings =
              (eventSnap.snapshot.value as Map)["ratings"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)['status'] != null) {
        setState(() {
          userRideRequestStatus =
              (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)['driverLocation'] != null) {
        double driverCurrenPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)['driverLocation']['latitude']
                .toString());
        double driverCurrenPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)['driverLocation']['longtitude']
                .toString());
        LatLng dirverCurrentPositionLatLng =
            LatLng(driverCurrenPositionLat, driverCurrenPositionLng);

        Direction driverAddress = Direction();
        driverAddress.locationLatitude = double.parse(
            (eventSnap.snapshot.value as Map)['driverLocation']['latitude']
                .toString());
        driverAddress.locationLongtitude = double.parse(
            (eventSnap.snapshot.value as Map)['driverLocation']['longtitude']
                .toString());

        Provider.of<AppInfor>(context, listen: false)
            .updateDriverLocation(driverAddress);

        //Status = accepted
        if (userRideRequestStatus == "accepted") {
          print("accepted :" + dirverCurrentPositionLatLng.toString());
          updateArrivalTimeToUserPickLocation(dirverCurrentPositionLatLng);
        }
        //status = arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
          String idRideRequest = referenceRideRequest!.key!;
          showDialog(
            context: context,
            builder: (context) => OrderDialogWidget(
              idRequest: idRideRequest,
            ),
          );
        }
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)['driverId'] != null) {
            String assignedDriverId =
                (eventSnap.snapshot.value as Map)["driverId"].toString();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RateDriverScreen(
                    assignedDriverId: assignedDriverId,
                  ),
                ));

            referenceRideRequest!.onDisconnect();
            tripDirectionDetailsInfoStreamSubscription!.cancel();
          }
        }
      }
    });
    onlineNearByAvailableDriversList =
        GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }

  updateArrivalTimeToUserPickLocation(dirverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      print(
          "anh da vao duoc ok $dirverCurrentPositionLatLng $userPickUpPosition");

      bool darkTheme =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      drawPolyLineFromOriginToDestination(darkTheme);

      var directionDetailsInfo =
          await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
              dirverCurrentPositionLatLng, userPickUpPosition);

      if (directionDetailsInfo == null) {
        print("anh da vao duoc return");
        return;
      }

      setState(() {
        print("anh da vao duoc update");
        driverRideStatus = "Tài xế đang đến trong: " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  String mapTheme = '';
  updateReachingTimeToUserDropOffLocation(driverCurrenPositionLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfor>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongtitude!);

      var directionDetailsInfo =
          await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
              driverCurrenPositionLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Going Towards Destination: " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers(String selectedVehicleType) async {
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel.delete the rideRequest Information
      referenceRideRequest!.remove();
      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoordiatedList.clear();
      });

      Fluttertoast.showToast(msg: 'No online nearlest Driver Available');
      Fluttertoast.showToast(msg: 'Search Apain. \n Restarting App');

      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplashScreen(),
            ));
      });
      return;
    }
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    print("Driver List: " + driversList.toString());

    String originAddress = Provider.of<AppInfor>(context, listen: false)
        .userPickUpLocation!
        .locationName
        .toString();
    String accessToken = await getAccessToken();
    print("access token ne" + accessToken);

    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]["car_details"]["type"] == selectedVehicleType) {
        sendNotificationToSelectedDriver(driversList[i]["token"],
            referenceRideRequest!.key!, accessToken, originAddress);
      }
    }
    String? idRequest;
    idRequest = referenceRideRequest!.key!;

    showSearchingForDriverContainer();
    await startListeningForDriverAcceptance(idRequest);
  }

  StreamSubscription? driverIdSubscription;

  Future<void> startListeningForDriverAcceptance(String idRequest) async {
    driverIdSubscription = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(idRequest)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapshot) {
      // Kiểm tra nếu `driverId` đã cập nhật và không còn là "waiting"
      if (eventRideRequestSnapshot.snapshot.value != null &&
          eventRideRequestSnapshot.snapshot.value != "waiting") {
        // Hủy lắng nghe sau khi tài xế chấp nhận
        driverIdSubscription!.cancel();

        // Hiển thị thông tin tài xế
        showUiForAssignedDriverInfo();
      }
    });
  }

  showUiForAssignedDriverInfo() {
    setState(() {
      watingResponefromDriverContainerheight = 0;
      searchLocationContainerHeight = 0;
      assingedDriverInfoContainerHeight = 250;
      showSuggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 0;
    });
  }

  //Chuyen doi tu danh sach id thanh thong tin
  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapShot) {
        var driverKeyInfo = dataSnapShot.snapshot.value;

        driversList.add(driverKeyInfo);
        print("driver key information = " + driversList.toString());
      });
    }
  }

  Future<String> getAccessToken() async {
    final serviceAccuntJson = {
      "type": "service_account",
      "project_id": "login-register-firebase-d2cd3",
      "private_key_id": "d260f5f150a25b4b6f244493d02acbaa91f8a2a4",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCyKs/1pN2Bngr3\n9jJha6wxWFSRtsuw9TBxqBCtHy70XcFP1bvmpwLd40v5a/Lx2BfEcDRCwNFlnLtW\nXnUpOE/dTAF4Gw0OMyRzmi5vwkdK1dsMZ/BiwN+fvr4YvNUel6GEh1kRpMlCH2fZ\ng57NoQRatbXSEDS6nnp1ubZF5TbOAbSk6U5i0ut/VKIEt3t5bI4RrXbKhUwW6N70\n6Zgkvw+muVat4et2MeA4GVyzmZ8Nubj4bap046h8dSNEgySRcJuhHosmTWmF7yUV\nHnBZJrc16RaJ7oENRnfMhFBX/bh7jgQQcOkUu799xFM3DlMo/u4lzNEBBaceyAqi\nuimp0xlNAgMBAAECggEAA7zwNggqeZC2TDOHJRIcP8DJrXD3XxQV2xyalPdFhez9\npE4orhMs9TjSnD4Oj9Jn1UBBaHEhM4+RQqOis6Wxz0PL+BghMv4Rsrc2aDPcSQ6p\nlN4NZhUD3BclZ+F2Wzj1M5GfZcZeTpvYEvE3ALtzGvAbC3g5kvzGNvgZgefoOXQ4\nrQ28IdbXKwaO0J4RSvvroYCvYjavExikSL+bR8NQiApuaBXFn5Xdmn0G/lXg8tcO\nx+UJvmui9dEpa9bPN6bFzOqgLLxQ+yb+k/XTdbXcWeAqTj2/uzO8dO05Hxr6mBNS\nwOCQmywJtvRkSC+HOMgSyRFVNTeI/3Wp0ishXdaOpQKBgQDx4n06h/kippG2diGT\n3pWCPTgByEKHRAWf5nIlThzuzkty0laQhpyR9auU7sw+A/JZOf4VStPWnTfgUcZd\n8Lpcv6gsKSandfSSUUIX6wuEUdl3PKBBsn4OkwjW3JpKvnCq8lZM9FFA6zVU+PHc\nWm66N6iS0AEF53yGOE9Sl5oTrwKBgQC8kHLugvpdcdqYTRJKdTELMU4B96LI9fFT\nRxYR9H9xlQnTv/TJ1W09z0BDI8deTD6Z12r+1IiUuE35OFOSmOTko/FrlPv9LlS8\nSsRvmlubM6aU/H4Z8PHOkfpxCup3aPnRueD9XM4fb1mzeekwL7H7faptwG0Jqjt0\nECDTiiNVwwKBgQDfmbaX7/Bvhrl2iXd6wS1Gax8mDqDpeAkXCqmEMNRwMYXvi993\n1OhRyV+m2qU1wuI6d3CY8EYpw8ZOeGm+l3U/nfBxek0ASvsecz187MwFssAsCIBA\nmycKhAOM0/tRkwCGFmWO199w+r2fYk36nCJ1xFPx+5Smh5pGXTF+sSQ+gwKBgHAY\nrzp7QrsqY/kGWElLQcyVkvo4bN1q1/vZ1pT19I1hPGZVRwB1kGueOWWwb2TvjoeG\nOGUlk8xVhIUTpxsPKYOCspJyDxuD33vQNtbhvHOXUQBg2dYyFo3m2is5gglarqiv\nB8GW2jJ1z62SW735nKUVH6v/KNMGEDH/JISdKkRhAoGAJWy9Yn1wHTIARlxvcAo+\nfdWTifID8ImaRTs8HhwShtiWAjUY4G8WAvgvUQWlV2T68oM5LY6bveTA5P5iS0ia\nc5IzMPDKn8OuAxUMaeLOQBwbIflJ54MT8dfoFvabzgT1OoR6FN7cFpOThwX9R2F4\nTVC9Gis1NCgnNs+gQq6kvmE=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-uber-clone-nhien36hk@login-register-firebase-d2cd3.iam.gserviceaccount.com",
      "client_id": "118070071108670684100",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-uber-clone-nhien36hk%40login-register-firebase-d2cd3.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccuntJson),
      scopes,
    );

    //get the access toke
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccuntJson),
      scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  Future<void> sendNotificationToSelectedDriver(String deviceToken,
      String ueRideRequestId, String accessToken, String originAddress) async {
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/login-register-firebase-d2cd3/messages:send';

    // Tạo notificationId dựa trên thời gian hiện tại
    String notificationId = DateTime.now().millisecondsSinceEpoch.toString();

    // Cấu hình thông báo tương tự như cấu trúc ban đầu của bạn
    final Map<String, dynamic> notificationPayload = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": "New Trip Request",
          "body": "Địa chỉ khách hàng: \n $originAddress.",
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": notificationId,
          "status": "done",
          "rideRequestId": ueRideRequestId,
        }
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Notification sent successfully!");
      } else {
        Fluttertoast.showToast(
            msg: "Failed to send notification: ${response.statusCode}");
        print("Error: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Exception while sending notification: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccessToken();
    loadTripsHistory();
    AssistantsMethod assistantsMethod = AssistantsMethod();
    assistantsMethod.generateAndGetToken();
    DefaultAssetBundle.of(context)
        .loadString('assets/mapTheme/standard.json')
        .then((value) {
      mapTheme = value;
      if (mapTheme == null) {
        print(mapTheme);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    //Tạo icon chứ không sử dụng thư viện
    createActiveNearByDriverIconMarker();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controler) {
                if (darkTheme == true) {
                  controler.setMapStyle(mapTheme);
                }
                _controllerGoogleMap.complete(controler);
                newGoogleMapController = controler;

                setState(() {});

                locationUserPosition();
              },
              // onCameraMove: (CameraPosition? position) {
              //   if (pickLocation != position) {
              //     setState(() {
              //       pickLocation = position!.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   if (pickLocation != null) {
              //     // Lấy latitude và longitude từ pickLocation
              //     double latitude = pickLocation!.latitude;
              //     double longitude = pickLocation!.longitude;

              //     // Gọi hàm với các tham số
              //     getAddressFromLatLng(latitude, longitude);
              //   }
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35),
            //     child: Image.asset(
            //       'images/pick.png',
            //       height: 45,
            //       width: 45,
            //     ),
            //   ),
            // ),

            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        darkTheme ? Colors.amber.shade400 : buttonColor,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: darkTheme ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: darkTheme
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    var reponseFromSearchScreen =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPlacesScreen()),
                                    );
                                    if (reponseFromSearchScreen ==
                                        "obtainedDropoff") {
                                      setState(() {
                                        openNavigationDrawer = false;
                                      });
                                    }
                                    await drawPolyLineFromOriginToDestination(
                                        darkTheme);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : buttonColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Địa chỉ của bạn đã gim',
                                              style: TextStyle(
                                                  color: darkTheme
                                                      ? Colors.amber.shade400
                                                      : buttonColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              Provider.of<AppInfor>(context)
                                                          .userPickUpLocation
                                                          ?.locationName !=
                                                      null
                                                  ? Provider.of<AppInfor>(
                                                              context)
                                                          .userPickUpLocation!
                                                          .locationName!
                                                          .substring(0, 24) +
                                                      "..."
                                                  : "Not Getting Address",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrecisePickupLocation(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Thả gim địa chỉ trên Map',
                                  style: TextStyle(
                                    color:
                                        darkTheme ? Colors.black : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme
                                      ? Colors.amber.shade400
                                      : buttonColor,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print("da show roi");
                                  if (Provider.of<AppInfor>(context,
                                              listen: false)
                                          .userPickUpLocation !=
                                      null) {
                                    showSuggestedRidesContainer();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Vui lòng chọn địa chỉ của bạn!');
                                  }
                                },
                                child: Text(
                                  'Xác nhận',
                                  style: TextStyle(
                                    color:
                                        darkTheme ? Colors.black : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkTheme
                                      ? Colors.amber.shade400
                                      : buttonColor,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            //Ui for suggested rides
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: showSuggestedRidesContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : buttonColor,
                                  borderRadius: BorderRadius.circular(2)),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              Provider.of<AppInfor>(context)
                                          .userPickUpLocation
                                          ?.locationName !=
                                      null
                                  ? Provider.of<AppInfor>(context)
                                          .userPickUpLocation!
                                          .locationName!
                                          .substring(0, 24) +
                                      "..."
                                  : "Not Getting Address",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Đề xuất xe',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicleType = "Car";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: selectedVehicleType == "Car"
                                      ? (darkTheme
                                          ? Colors.amber.shade400
                                          : buttonColor)
                                      : (darkTheme
                                          ? Colors.black54
                                          : Colors.grey[100])),
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/Car1.png',
                                      scale: 4.2,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('Car',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedVehicleType == "Car"
                                              ? (darkTheme
                                                  ? Colors.black
                                                  : Colors.white)
                                              : (darkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        )),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "> 1 tấn rác",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicleType = "Bike";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: selectedVehicleType == "Bike"
                                      ? (darkTheme
                                          ? Colors.amber.shade400
                                          : buttonColor)
                                      : (darkTheme
                                          ? Colors.black54
                                          : Colors.grey[100])),
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/bike.png',
                                      scale: 4.2,
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text('Bike',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedVehicleType == "Bike"
                                              ? (darkTheme
                                                  ? Colors.black
                                                  : Colors.white)
                                              : (darkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        )),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "< 150kg rác",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedVehicleType != "") {
                              saveRideRequestInformation(selectedVehicleType);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'Vui lòng chọn xe.');
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : buttonColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Tìm kiếm tài xế',
                                style: TextStyle(
                                  color:
                                      darkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //Requesting A Ride
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        color: darkTheme ? Colors.amber.shade400 : buttonColor,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          "Chờ tài xế chấp nhận",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          referenceRideRequest!.remove();
                          setState(() {
                            searchingForDriverContainerHeight = 0;
                            showSuggestedRidesContainerHeight = 0;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Text(
                          "Hủy bỏ",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Container(
                height: assingedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        driverRideStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.grey : Colors.grey.shade300,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : lightColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(
                                  Icons.person,
                                  color:
                                      darkTheme ? Colors.black : Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        driverRatings,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset("images/Car1.png", scale: 3),
                              Text(
                                driverCarDetails,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.grey : Colors.grey[300],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _makePhoneCall("tel: ${driverPhone}");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                darkTheme ? Colors.amber.shade400 : buttonColor,
                            foregroundColor:
                                darkTheme ? Colors.black : Colors.white),
                        icon: Icon(Icons.phone),
                        label: Text("Gọi điện cho tài xế"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(20),
            //     child: Text(
            //       Provider.of<AppInfor>(context)
            //                   .userPickUpLocation
            //                   ?.locationName !=
            //               null
            //           ? Provider.of<AppInfor>(context)
            //                   .userPickUpLocation!
            //                   .locationName!
            //                   .substring(0, 24) +
            //               "..."
            //           : "Not Getting Address",
            //       overflow: TextOverflow.visible,
            //       softWrap: true,
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
