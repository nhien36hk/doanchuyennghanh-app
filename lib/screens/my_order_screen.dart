import 'package:app_intern/constants.dart';
import 'package:app_intern/widgets/request_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  List<String> _myOrder = ['Yêu Cầu', 'Đã Xác Nhận', 'Hoàn Thành'];
  int _pageIdx = 0;
  final _pages = [
    RequestWidget(),
    Center(
      child: Text('Đã xác nhận'),
    ),
     Center(
      child: Text('Lịch sử'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _myOrder.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _pageIdx = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 43, vertical: 15),
                              decoration: BoxDecoration(
                                color: _pageIdx == index
                                    ? buttonColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Text(
                                _myOrder[index],
                                style: TextStyle(
                                    color: _pageIdx == index
                                        ? Colors.white
                                        : buttonColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              _pages[_pageIdx]
            ],
          ),
        ),
      ),
    );
  }
}
