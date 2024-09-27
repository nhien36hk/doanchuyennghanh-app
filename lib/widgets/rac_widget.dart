import 'package:flutter/material.dart';

class RacWidget extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const RacWidget({Key? key, required this.name, required this.price, required this.image}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
      border: Border.all(color: Colors.black.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Thêm để đảm bảo cột chiếm hết chiều rộng
      children: [
        // Thêm kích thước cho hình ảnh
        Image.asset(
          image,
          fit: BoxFit.cover,
          height: 100, // Hoặc thay đổi theo nhu cầu
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(price),
            ],
          ),
        ),
      ],
    ),
  );
}

}
