import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation {
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? orginAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;

  UserRideRequestInformation({
    this.originLatLng,
    this.destinationLatLng,
    this.orginAddress,
    this.destinationAddress,
    this.rideRequestId,
    this.userName,
    this.userPhone,
  });
}