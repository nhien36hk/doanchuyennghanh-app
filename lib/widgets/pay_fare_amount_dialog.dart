import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/model/payDetail_model.dart';
import 'package:drivers_android/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vnpay_flutter/vnpay_flutter.dart';

class PayFareAmountDialog extends StatefulWidget {
  PayFareAmountDialog({super.key, this.fareAmount, this.idRideRequest});

  double? fareAmount;
  String? idRideRequest;

  @override
  State<PayFareAmountDialog> createState() => _PayFareAmountDialogState();
}

class _PayFareAmountDialogState extends State<PayFareAmountDialog> {
  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(firebaseAuth.currentUser!.uid)
            .child('earnings')
            .set(driverTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(firebaseAuth.currentUser!.uid)
            .child('earnings')
            .set(totalFareAmount.toString());
      }
    });
  }

  payCash() async {
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("Pay Status")
        .set("Paid");

    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("Pay Information")
        .child("Pay Method")
        .set("Cash");
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("status")
        .set("ended");

    saveFareAmountToDriverEarnings(widget.fareAmount!);
  }

  savePayDetail(Map<String, dynamic> PayInfor) async {
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("Pay Status")
        .set("Paid");
    PaydetailModel payInformation = PaydetailModel(
        amount: PayInfor['vnp_Amount'],
        bankType: PayInfor['vnp_BankCode'],
        cardType: PayInfor['vnp_CardType'],
        codeBank: PayInfor['vnp_BankTranNo'],
        payDate: PayInfor['vnp_PayDate'],
        status:
            PayInfor['vnp_ResponseCode'] == '00' ? "Thành công" : "Thất bại");
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("Pay Information")
        .update({
      "Pay Method": "Bank", // Lưu phương thức thanh toán
      ...payInformation.toMap(), // Lưu thông tin chi tiết thanh toán
    });
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.idRideRequest!)
        .child("status")
        .set("ended");

    saveFareAmountToDriverEarnings(widget.fareAmount!);
  }

  Future<void> onPayment() async {
    String responseCode = '';
    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.0.1',
      tmnCode: 'E860C851',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Pay ${widget.fareAmount} VND',
      amount: widget.fareAmount!,
      returnUrl:
          'https://sandbox.vnpayment.vn/return_url', // URL trả kết quả thanh toán
      ipAdress: '192.168.10.10',
      vnpayHashKey: 'YJ4D3ITOSS47UVVMKH920QJJV4POIBKB',
      vnPayHashType: VNPayHashType.HMACSHA512,
      vnpayExpireDate: DateTime.now().add(const Duration(hours: 1)),
    );

    await VNPAYFlutter.instance.show(
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) {
        setState(() {
          responseCode = params['vnp_ResponseCode'] ?? 'No Response';
        });
        // Điều hướng hoặc hiển thị trạng thái thành công
        Navigator.pop(context, "Payment Successful");
        _showPaymentResult("Thanh toán thành công", params);
      },
      onPaymentError: (params) {
        setState(() {
          responseCode = 'Error';
        });
        // Điều hướng hoặc hiển thị trạng thái thất bại
        Navigator.pop(context, "Payment Failed");
        _showPaymentResult("Thanh toán thất bại", params);
      },
    );
  }

  void _showPaymentResult(String title, Map<String, dynamic> params) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    savePayDetail(params);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Đầu tiên là thông báo giao dịch thành công
                Text(
                  "Thông tin chi tiết giao dịch!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Hiển thị thông tin thanh toán
                _buildPaymentDetailRow(
                    "Số tiền thanh toán:", "${params['vnp_Amount']} VND"),
                _buildPaymentDetailRow("Mã ngân hàng:", params['vnp_BankCode']),
                _buildPaymentDetailRow(
                    "Số giao dịch ngân hàng:", params['vnp_BankTranNo']),
                _buildPaymentDetailRow("Loại thẻ:", params['vnp_CardType']),
                _buildPaymentDetailRow(
                    "Thông tin đơn hàng:", params['vnp_OrderInfo']),
                _buildPaymentDetailRow(
                    "Thời gian giao dịch:", params['vnp_PayDate']),
                _buildPaymentDetailRow(
                    "Mã phản hồi:",
                    params['vnp_ResponseCode'] == '00'
                        ? 'Thành công'
                        : 'Thất bại'),

                SizedBox(height: 20),
                // Phần cuối với nút OK
                ElevatedButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplashScreen(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        darkTheme ? Colors.amber.shade400 : buttonColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.blue,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              widget.fareAmount.toString().toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.fareAmount.toString() + "đ",
              style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                  fontSize: 50),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Đây là tổng số tiền phế liệu mà bạn phải trả!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Future.delayed(Duration(microseconds: 10000), () async {
                        payCash();
                        Navigator.pop(context, "Cash Paid");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ));
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pay Cash",
                          style: TextStyle(
                            fontSize: 20,
                            color: darkTheme ? Colors.black : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.fareAmount.toString() + "đ",
                          style: TextStyle(
                              color: darkTheme ? Colors.black : Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Future.delayed(Duration(microseconds: 10000), () {
                        Navigator.pop(context, "Cash Paid");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ));
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            onPayment();
                          },
                          child: Text(
                            "Pay VNPAY",
                            style: TextStyle(
                              fontSize: 20,
                              color: darkTheme ? Colors.black : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          widget.fareAmount.toString() + "đ",
                          style: TextStyle(
                              color: darkTheme ? Colors.black : Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
