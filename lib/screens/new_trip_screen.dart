import 'dart:async';
import 'dart:typed_data';

import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/model/user_ride_request_information.dart';
import 'package:drivers_android/splashScreen/splash_screen.dart';
import 'package:drivers_android/widgets/pay_fare_amount_dialog.dart';
import 'package:drivers_android/widgets/progress_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  NewTripScreen({super.key, this.userRideRequestDetails});

  UserRideRequestInformation? userRideRequestDetails;

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoolgeMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Đã đến";

  Set<Marker> setOffMarKers = Set<Marker>();
  Set<Circle> setOffCircle = Set<Circle>();
  Set<Polyline> setOffPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCorrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatorMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

//Step 1: When driver accepts the user ride request
//originLatLng = driverCurrent location
//destinationLatLng = userPickUpLocation

//Step 2: When driver pickps up the user in his car
//originLatLng = userPickUpLocation
//destinationLatLng = userDroppOfLocation
  Future<void> drawPolylineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    Navigator.pop(context);
    var directionDetailsInfo =
        await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
            destinationLatLng, originLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCorrdinates.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCorrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOffPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amber.shade400 : buttonColor,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCorrdinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOffPolyline.add(polyline);
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

    newTripGoolgeMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOffMarKers.add(originMarker);
      setOffMarKers.add(destinationMarker);
    });

    Circle orginCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);
    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng);

    setState(() {
      setOffCircle.add(orginCircle);
      setOffCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

//Cập nhật vị trí và marker realtime
  getDriverLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
          markerId: MarkerId("AnimatedMarker"),
          position: latLngLiveDriverPosition,
          icon: iconAnimatorMarker!,
          infoWindow: InfoWindow(title: "This is your position"));
      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 18);
        newTripGoolgeMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOffMarKers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOffMarKers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationtimeAtRealTime();

      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longtitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationtimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;
      destinationLatLng = widget.userRideRequestDetails!.originLatLng;

      var directionInformation =
          await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
          print("Thoi gian duratin" + durationFromOriginToDestination);
        });

        isRequestDirectionDetails = false;
      }
    }
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

  void createDriverIconMarker() async {
    if (iconAnimatorMarker == null) {
      iconAnimatorMarker = await createResizedBitmapDescriptor('images/car.png',
          width: 150, height: 150);
    }
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);
    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longtitude": driverCurrentPosition!.longitude.toString(),
    };

    if (databaseReference.child("driverId") != "waiting") {
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("drivername").set(onlineDriverData.name);
      databaseReference.child("driverphone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("car_details").set(
          onlineDriverData.car_model.toString() +
              " " +
              onlineDriverData.car_number.toString() +
              " (" +
              onlineDriverData.car_color.toString() +
              ")");

      saveRideRequestIdToDriverHistory();
    } else {
      Fluttertoast.showToast(
          msg:
              "This ride is already accepted by another driver. \n Reloading the App");
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(),
          ));
    }
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");
    tripHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }


  subscriptionOrder() {
    StreamSubscription<DatabaseEvent>? orderStreamSubscription;
    orderStreamSubscription = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .onValue
        .listen((snapShot) async {
      if ((snapShot.snapshot.value as Map)['fareAmount'] != null) {
        if ((snapShot.snapshot.value as Map)['Pay Status'] == "Not Paid") {
          var fareAmount = (snapShot.snapshot.value as Map)['fareAmount'];
          var response = await showDialog(
            context: context,
            builder: (BuildContext context) => PayFareAmountDialog(
              fareAmount: double.parse(fareAmount),
              idRideRequest: widget.userRideRequestDetails!.rideRequestId,
            ),
          );
        }
      }
    });
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Vui lòng chờ...",
      ),
    );

    DatabaseReference dataRef = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("Pay Status");

    DataSnapshot dataSnapshot = await dataRef.get();

// Kiểm tra nếu dữ liệu tồn tại trước khi đọc giá trị
    if (dataSnapshot.exists) {
      String payStatus = dataSnapshot.value as String;

      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("fareAmount"); // Ép kiểu giá trị sang String

      DataSnapshot refSnap = await ref.get();

      String fareAmount = (refSnap.value as String);

      if (payStatus == "Paid") {
        FirebaseDatabase.instance
            .ref()
            .child("All Ride Requests")
            .child(widget.userRideRequestDetails!.rideRequestId!)
            .child("status")
            .set("ended");

        Navigator.pop(context);
        // Thực hiện hành động nếu đã thanh toán
      } else if (payStatus == "Not Paid") {
        var response = await showDialog(
          context: context,
          builder: (BuildContext context) => PayFareAmountDialog(
            fareAmount: double.parse(fareAmount),
            idRideRequest: widget.userRideRequestDetails!.rideRequestId,
          ),
        );
      } else {
        print("Trạng thái thanh toán không xác định: $payStatus");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Vui lòng nhắc người dùng cập nhật giá tổng đơn hàng");
    }

  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: mapPadding),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: _kGooglePlex,
          circles: setOffCircle,
          markers: setOffMarKers,
          polylines: setOffPolyline,
          onMapCreated: (GoogleMapController controler) {
            _controllerGoogleMap.complete(controler);
            newTripGoolgeMapController = controler;

            setState(() {
              mapPadding = 350;
            });

            var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude);

            var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

            drawPolylineFromOriginToDestination(
                driverCurrentLatLng, userPickUpLatLng!, darkTheme);

            getDriverLocationUpdatesAtRealTime();
          },
        ),

        //UI
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6)),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      durationFromOriginToDestination,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.amber.shade400 : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkTheme
                                ? Colors.amber.shade400
                                : Colors.black,
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () {},
                          icon: Icon(
                            Icons.phone,
                            color: darkTheme
                                ? Colors.amber.shade400
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
                              widget.userRideRequestDetails!.orginAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme
                                    ? Colors.amberAccent
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            darkTheme ? Colors.amber.shade400 : buttonColor,
                      ),
                      onPressed: () async {
                        //[Driver has arrived at user PickUp Location] - Arrived Button
                        if (rideRequestStatus == "accepted") {
                          rideRequestStatus = "arrived";

                          FirebaseDatabase.instance
                              .ref()
                              .child('All Ride Requests')
                              .child(
                                  widget.userRideRequestDetails!.rideRequestId!)
                              .child('status')
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle =
                                "Đang chờ khách hàng tính tổng phế liệu";
                          });
                          // Thoi giõi đơn order của khách hàng
                          subscriptionOrder();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) => ProgressDialog(
                              message: "Loading...",
                            ),
                          );

                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        } else {
                          rideRequestStatus = "ended";
                          Fluttertoast.showToast(
                              msg:
                                  "Vui lòng nhắc người dùng cập nhật giá tổng đơn hàng");
                        }
                      },
                      icon: Icon(
                        Icons.directions_car,
                        color: darkTheme ? Colors.black : Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: TextStyle(
                          color: darkTheme ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
