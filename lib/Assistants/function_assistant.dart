import 'package:geolocator/geolocator.dart';

class FunctionAssistant {
  static Future<void> checkLocationPermission() async {
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
}