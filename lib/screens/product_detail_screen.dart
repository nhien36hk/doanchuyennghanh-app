import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trippo_app/global/global.dart';

class ProductDetail extends StatefulWidget {
  final String id;

  ProductDetail({super.key, required this.id});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map<String, dynamic>? productData;

  @override
  void initState() {
    super.initState();
    fetchProductData(widget.id); // Gọi hàm lấy dữ liệu khi widget được khởi tạo
  }

  Future<void> fetchProductData(String id) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (snapshot.exists) {
        setState(() {
          productData = snapshot.data() as Map<String, dynamic>; // Lưu dữ liệu vào biến
        });
      } else {
        print('Product not found');
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bảng giá phế liệu',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: buttonColor,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: productData == null // Kiểm tra xem dữ liệu đã được lấy chưa
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    height: 350,
                    image: NetworkImage(productData!['image']), // Hình ảnh từ URL
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 30),
                  Text(
                    productData!['name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: Colors.grey)),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text(productData!['description']),
                  )
                ],
              ),
            ),
    );
  }
}
