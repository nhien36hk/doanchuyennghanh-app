import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;
  String? ratings;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.car_details,
    this.driverName,
    this.ratings,
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapShot){
    time = (dataSnapShot.value as Map)['time'];
    originAddress = (dataSnapShot.value as Map)['originAddress'];
    destinationAddress = (dataSnapShot.value as Map)['destinationAddress'];
    status = (dataSnapShot.value as Map)['status'];
    fareAmount = (dataSnapShot.value as Map)['fareAmount'];
    car_details = (dataSnapShot.value as Map)['car_details'];
    driverName = (dataSnapShot.value as Map)['drivername'];
    ratings = (dataSnapShot.value as Map)['ratings'];
  }
}