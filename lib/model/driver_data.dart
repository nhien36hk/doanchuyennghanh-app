class DriverData {
  String? id;
  String? name;
  String? phone;
  String? address;
  String? car_model;
  String? car_color;
  String? email;
  String? car_number;
  String? car_type;
  String? ratings;

  DriverData({
    this.id,
    this.address,
    this.email,
    this.name,
    this.phone,
    this.car_color,
    this.car_model,
    this.car_number,
    this.car_type,
    this.ratings,
  });

  @override
  String toString() {
    return 'DriverData{id: $id, name: $name, phone: $phone, email: $email, address: $address, ratings: $ratings, car_color: $car_color, car_model: $car_model, car_number: $car_number, car_type: $car_type}';
  }
}
