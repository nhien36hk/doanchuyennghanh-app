import 'package:app_intern/constants.dart';
import 'package:app_intern/models/product.dart';
import 'package:app_intern/screens/product_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  Rx<List<Product>> _product = Rx<List<Product>>([]);
  List<Product> get product => _product.value;
  Rx<Product?> _productDetail = Rx<Product?>(null);
  Product? get productDetail => _productDetail.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _product.bindStream(
        firestore.collection('products').snapshots().map((QuerySnapshot query) {
      List<Product> retValue = [];
      for (var element in query.docs) {
        retValue.add(Product.fromSnap(element));
      }

      return retValue;
    }));
  }

  void findProductDetail(String id) async {
    await firestore
        .collection('products')
        .doc(id)
        .snapshots()
        .listen((DocumentSnapshot snap) {
      _productDetail.value = Product.fromSnap(snap);
    });
  }
}
