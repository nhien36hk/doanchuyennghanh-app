import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/direction.dart';

class PrecisePickupLocation extends StatefulWidget {
  const PrecisePickupLocation({super.key});

  @override
  State<PrecisePickupLocation> createState() => _PrecisePickupLocationState();
}

class _PrecisePickupLocationState extends State<PrecisePickupLocation> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  Position? userCurrentPosition;
  double bottomPaddingOfMap = 40;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
    } catch (e) {
      print("Lỗi lấy vị trí người dùng: $e");
    }
  }

  String mapTheme = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controler) {
              controler.setMapStyle(mapTheme);
              _controllerGoogleMap.complete(controler);
              newGoogleMapController = controler;

              setState(() {
                bottomPaddingOfMap = 40;
              });
              locationUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position) {
                setState(() {
                  pickLocation = position!.target;
                });
              }
            },
            onCameraIdle: () {
              if (pickLocation != null) {
                // Lấy latitude và longitude từ pickLocation
                double latitude = pickLocation!.latitude;
                double longitude = pickLocation!.longitude;

                // Gọi hàm với các tham số
                getAddressFromLatLng(latitude, longitude);
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Image.asset(
                'images/pick.png',
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Text(
                Provider.of<AppInfor>(context)
                            .userPickUpLocation
                            ?.locationName !=
                        null
                    ? Provider.of<AppInfor>(context)
                            .userPickUpLocation!
                            .locationName!
                            .substring(0, 40) +
                        "..."
                    : "Not Getting Address",
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      darkTheme ? Colors.amber.shade400 : Colors.blue,
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: Text('Set Current Location', style: TextStyle(color: Colors.white),),

              ),
            ),
          )
        ],
      ),
    );
  }
}
