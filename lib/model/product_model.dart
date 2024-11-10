import 'package:firebase_database/firebase_database.dart';

class Product {
  String? name;
  String? id;
  String? price;
  String? description;
  String? image;

  Product({
    this.description,
    this.image,
    this.name,
    this.id,
    this.price,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'image': image,
        'name': name,
        'price': price,
        'id': id,
      };

  // Constructor từ DataSnapshot
  Product.fromSnapShot(DataSnapshot snap) {
    // Kiểm tra nếu snapshot tồn tại
    if (snap.exists) {
      var snapshotValue = snap.value as Map<dynamic, dynamic>;

      // Gán giá trị cho các thuộc tính của Product
      name = snapshotValue['name'];
      price = snapshotValue['price'];
      description = snapshotValue['description'];
      image = snapshotValue['image'];
      id = snap.key; // Sử dụng key của snapshot làm ID
    }
  }
}
