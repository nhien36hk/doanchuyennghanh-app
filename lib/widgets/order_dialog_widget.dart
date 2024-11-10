import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/widgets/order_widget.dart';

class OrderDialogWidget extends StatefulWidget {
  OrderDialogWidget({super.key, this.idRequest});

  String? idRequest;

  @override
  State<OrderDialogWidget> createState() => _OrderDialogWidgetState();
}

class _OrderDialogWidgetState extends State<OrderDialogWidget> {
  saveTotalPay() async {
    // Cập nhật giá trị fareAmount trong Firebase
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRequest!)
        .child("fareAmount")
        .set((Provider.of<AppInfor>(context, listen: false).totalPay)
            .toString());
    
       await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRequest!)
        .child("Pay Status")
        .set("Not Paid");
    
    // Đảm bảo chỉ đóng dialog khi không có lỗi
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppInfor>(context, listen: false).removeTotalPay();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    var productList =
        Provider.of<AppInfor>(context, listen: false).allProductsList;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Tổng đơn hàng",
              style: TextStyle(
                color: darkTheme ? Colors.amber.shade400 : buttonColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 15),
            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : buttonColor,
            ),
            SizedBox(height: 15),
            // Consumer to listen for updates in totalPay
            Consumer<AppInfor>(
              builder: (context, appInfor, child) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return OrderWidget(
                        product: appInfor.allProductsList[index]);
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: appInfor.allProductsList.length,
                );
              },
            ),
            SizedBox(height: 10),
            // Display the updated total price
            Consumer<AppInfor>(
              builder: (context, appInfor, child) {
                return Text(
                  "Tổng tiền toàn bộ đơn hàng: ${appInfor.totalPay} VND",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    darkTheme ? Colors.amber.shade400 : buttonColor,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
              onPressed: () {
                saveTotalPay(); // Lưu giá trị và đóng dialog ngay lập tức
              },
              child: Text(
                "Xác nhận",
                style: TextStyle(
                    color: darkTheme ? Colors.black : Colors.white,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
