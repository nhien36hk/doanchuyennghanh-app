import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Nhớ import nếu bạn chưa
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trippo_app/Assistants/assistants_method.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/product_model.dart';
import 'package:trippo_app/screens/product_detail_screen.dart';

class MainTabScreen extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  PageController controller = PageController();
  final List<String> desPages = [
    'images/1.jpg',
    'images/2.jpg',
    'images/3.jpg',
  ];

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    List<Product> productsList = [];

    try {
      // Lấy dữ liệu từ Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      for (var doc in querySnapshot.docs) {
        // Tạo đối tượng Product từ dữ liệu và thêm vào danh sách
        productsList.add(Product(
          name: doc['name'],
          price: doc['price'],
          description: doc['description'],
          image: doc['image'],
          id: doc.id, // Gán ID từ khóa của sản phẩm
        ));
      }

      // Cập nhật state với danh sách sản phẩm mới
      setState(() {
        products = productsList;
        Provider.of<AppInfor>(context, listen: false).updateOverAllProducts(productsList);
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 30),
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
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: buttonColor),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SmoothPageIndicator(
              count: desPages.length,
              controller: controller,
              effect: ExpandingDotsEffect(
                activeDotColor: buttonColor,
                dotColor: Colors.grey,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            SizedBox(height: 15),
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
                    SizedBox(height: 5),
                    Text(
                      'Đổi quà',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(width: 20),
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
                    SizedBox(height: 5),
                    Text(
                      'Fanpage',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Bảng giá phế liệu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.width,
              child: MasonryGridView.builder(
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: products.length, // Cập nhật số lượng sản phẩm
                itemBuilder: (context, index) {
                  final rac = products[index];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                  id: rac.id
                                      .toString()), // Truyền ID của sản phẩm
                            ));
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
                                    rac.image.toString(),
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
                                    SizedBox(height: 5),
                                    Text(
                                      rac.name.toString(),
                                      style: TextStyle(
                                        color: buttonColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      rac.price.toString(),
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
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
