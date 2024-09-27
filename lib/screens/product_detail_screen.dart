import 'package:app_intern/constants.dart';
import 'package:app_intern/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetail extends StatelessWidget {
  String id;
  ProductDetail({super.key, required this.id});

  final ProductController productController = Get.put(ProductController());


  @override
  Widget build(BuildContext context) {
    productController.findProductDetail(id);
    return Obx(() {
      final data = productController.productDetail;
       if (data == null) {
        return Center(child: CircularProgressIndicator()); // Hiển thị khi dữ liệu chưa sẵn sàng
      }
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                height: 350,
                image: AssetImage('assets/images/object/1.png'),
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                data.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.grey)),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                    data!.description),
              )
            ],
          ),
        ),
      );
    });
  }
}
