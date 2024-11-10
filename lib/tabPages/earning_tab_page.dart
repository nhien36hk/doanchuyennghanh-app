import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:drivers_android/screens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningTabPage extends StatefulWidget {
  const EarningTabPage({super.key});

  @override
  State<EarningTabPage> createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color: darkTheme ? Colors.amberAccent : Color.fromARGB(255, 243, 125, 92),
      child: Column(
        children: [
          Container(
            color: darkTheme ? Colors.black : Color.fromARGB(255, 243, 125, 92),
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    'Tổng thu nhập',
                    style: TextStyle(
                        color: darkTheme ? Colors.amber.shade400 : Colors.white,
                        fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    Provider.of<AppInfor>(context, listen: false)
                            .driverTotalEarnings.toStringAsFixed(0) +
                        'đ',
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripsHistoryScreen(),
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkTheme ? Colors.white54: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              )
              
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(onlineDriverData.car_type == "Car"
                      ? 'images/Car1.png'
                      : onlineDriverData.car_type == "Bike"
                          ? 'images/bike.png'
                          : 'images/delivery.png', scale: 3,),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Tổng số chuyến hoàn thành',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Text(
                        Provider.of<AppInfor>(context)
                            .allTripsHistoryInformationList
                            .length
                            .toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
