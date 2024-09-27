import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String name;
  String id;
  String price;
  String description;
  String image;

  Product(
      {required this.description,
      required this.image,
      required this.name,
      required this.id,
      required this.price});

  Map<String, dynamic> toJson() => {
        'description': description,
        'image': image,
        'name': name,
        'price': price,
        'id' : id,
      };

  static Product fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Product(
      description: snapshot['description'],
      name: snapshot['name'],
      price: snapshot['price'],
      image: snapshot['image'],
      id : snapshot['id']
    );
  }
}
