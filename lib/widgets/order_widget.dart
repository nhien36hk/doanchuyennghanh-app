import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/product_model.dart';

class OrderWidget extends StatefulWidget {
  final Product? product;

  OrderWidget({super.key, this.product});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  int selectedKg = 0; // Số kg mặc định là 1
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
  }

  void calculateTotalPrice() {
    int pricePerKg = int.tryParse(widget.product?.price ?? '0') ?? 0;
    setState(() {
      totalPrice = pricePerKg * selectedKg;
    });

    // Cập nhật giá trị tổng vào provider sau khi tính toán
    Provider.of<AppInfor>(context, listen: false).updateTotalPay(totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: darkTheme ? Colors.amber.shade400 : buttonColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product?.name ?? "No name",
                style:
                    TextStyle(color: darkTheme ? Colors.black : Colors.white),
              ),
              Text("${widget.product!.price!} /kg",
                  style:
                      TextStyle(color: darkTheme ? Colors.black : Colors.white))
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Chọn số kg: ",
                style:
                    TextStyle(color: darkTheme ? Colors.black : Colors.white),
              ),
              SizedBox(width: 10),
              DropdownButton<int>(
                value: selectedKg == 0
                    ? 1
                    : selectedKg, // Nếu selectedKg là 0, chọn giá trị 1
                items: List.generate(
                        20, (index) => index + 1) // Chọn từ 1 đến 20 kg
                    .map((kg) => DropdownMenuItem(
                          value: kg,
                          child: Text('$kg kg'),
                        ))
                    .toList(),
                onChanged: (newKg) {
                  setState(() {
                    selectedKg = newKg!;
                    calculateTotalPrice(); // Cập nhật tổng tiền khi thay đổi số kg
                  });
                },
              )
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Tổng tiền: $totalPrice VND",
            style: TextStyle(
              color: darkTheme ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
