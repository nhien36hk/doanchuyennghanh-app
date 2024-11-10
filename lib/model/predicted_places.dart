class PredictedPlaces {
  String? place_id; // Nếu không có, bạn có thể xóa
  String? main_text; // Địa điểm
  String? secondary_text; // Địa chỉ
  double? locationLatitude; // Tọa độ vĩ độ
  double? locationLongitude; // Tọa độ kinh độ

  PredictedPlaces({
    this.place_id,
    this.main_text,
    this.secondary_text,
    this.locationLatitude,
    this.locationLongitude,
  });

  // Phương thức từ JSON
  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    place_id = jsonData["place_id"]; // Lưu place_id nếu có
    main_text = jsonData["display_name"]; // Địa điểm
    secondary_text = jsonData["address"]["state"] ?? jsonData["address"]["name"] ?? ""; // Địa chỉ
    
    // Chuyển đổi từ String sang double
    locationLatitude = double.tryParse(jsonData["lat"].toString());
    locationLongitude = double.tryParse(jsonData["lon"].toString());
  }
}
