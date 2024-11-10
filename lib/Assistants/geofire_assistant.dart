import 'package:trippo_app/model/active_nearby_available_drivers.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList = [];

  static void deleteOffineDriverfromList(String driver_id){
    int index_number = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driver_id,);
    if(index_number != -1){
      activeNearbyAvailableDriversList.removeAt(index_number);
    }
  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableDrivers driverUpdate){
    int index_number = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverUpdate.driverId,);
    if(index_number != -1){
      activeNearbyAvailableDriversList[index_number].locationLatitude = driverUpdate.locationLatitude;
      activeNearbyAvailableDriversList[index_number].locationLongtitude = driverUpdate.locationLongtitude;
    } 
  }
}
