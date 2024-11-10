import 'dart:io';

import 'package:drivers_android/model/direction.dart';
import 'package:drivers_android/model/trips_history_model.dart';
import 'package:flutter/material.dart';

class AppInfor extends ChangeNotifier {
  Direction? userPickUpLocation, userDropOffLocation;
  int countTotaltrips = 0;
  List<String> historyTripsKeysList = [];
  double driverTotalEarnings = 0.0;
  String driverAverageRatings = '0';
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Direction userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Direction dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotaltrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory) {
    allTripsHistoryInformationList.add(eachTripHistory);
    Notification;
  }

  updateDriverTotalEarnings(String driverEarnings) {
    driverTotalEarnings += double.parse(driverEarnings);
  }
  updateDriverAverageRatings(String driverRatings) {
    driverAverageRatings  = driverRatings;
  }
}
