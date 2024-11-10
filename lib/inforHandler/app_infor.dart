import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trippo_app/model/direction.dart';
import 'package:trippo_app/model/product_model.dart';
import 'package:trippo_app/model/trips_history_model.dart';

class AppInfor extends ChangeNotifier{
  Direction? userPickUpLocation, userDropOffLocation, driverLocation;
  int countTotaltrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];
  List<Product> allProductsList = [];
  int totalPay = 0;

  void updatePickUpLocationAddress(Direction userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDriverLocation(Direction driverAddress){
    driverLocation = driverAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Direction dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter){
    countTotaltrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList){
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
    allTripsHistoryInformationList.add(eachTripHistory);
     notifyListeners();
  }

  updateOverAllProducts(List<Product> productList ){
    allProductsList = productList;
    notifyListeners();
  }

  updateTotalPay(int fareAmount){
    totalPay += fareAmount;
    notifyListeners();
  }

  removeTotalPay(){
    totalPay = 0;
    notifyListeners();
  }
} 