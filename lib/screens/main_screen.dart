import 'package:app_intern/constants.dart';
import 'package:app_intern/controller/product_controller.dart';
import 'package:app_intern/models/object.dart';
import 'package:app_intern/screens/product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  PageController controller = PageController();

  final ProductController productController = Get.put(ProductController());

  final List<String> desPages = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
  ];

  final List<Object_Rac> object = [
    Object_Rac(
        name: 'GIẤY BÁO',
        price: '4.000 đ',
        image: 'assets/images/object/1.png',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'GIẤY HỒ SƠ',
        price: '2.000 đ',
        image: 'assets/images/object/1.png',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'GIẤY THÙNG',
        price: '2.000 đ',
        image: 'assets/images/object/1.png',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'SẮT ĐẶC',
        price: '2.000 đ',
        image: 'assets/images/object/1.png',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'SẮT TÔN',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'MỦ MÀU',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'CHAI PET',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'LON NHÔM',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'NHÔM CỬA',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
    Object_Rac(
        name: 'ĐỒNG THAU',
        price: '2.000 đ',
        image: 'assets/images/1.jpg',
        desription:
            'Giấy báo (không bao gồm các loại tạp chí giấy bóng, decal)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width - 20,
                child: PageView.builder(
                  controller: controller,
                  itemCount: desPages.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(desPages[index]),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: buttonColor)),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SmoothPageIndicator(
                  count: desPages.length,
                  controller: controller,
                  effect: ExpandingDotsEffect(
                    activeDotColor: buttonColor,
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                  )),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        child: Icon(
                          FontAwesomeIcons.gift,
                          size: 30,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        padding: EdgeInsets.all(12),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Đổi quà',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Container(
                        child: Icon(
                          FontAwesomeIcons.facebook,
                          size: 30,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        padding: EdgeInsets.all(12),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Fanpage',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                'Bảng giá phế liệu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.width,
                child: MasonryGridView.builder(
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    final rac = productController.product[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(id: rac.id,),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(0),
                          height: 105,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: buttonColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      rac.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 100, // Chiều cao cố định cho ảnh
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        rac.name,
                                        style: TextStyle(
                                            color: buttonColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        rac.price,
                                        style: TextStyle(
                                          color: buttonColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: productController.product.length,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
