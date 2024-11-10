import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:drivers_android/widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        title: Text(
          "Lịch sử đơn thu gom",
          style: TextStyle(
            color: darkTheme ? Colors.amber : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              return Card(
                color: darkTheme ? Colors.black : Colors.grey[100],
                shadowColor: Colors.transparent,
                child: HistoryDesignUi(
                  tripsHistoryModel:
                      Provider.of<AppInfor>(context, listen: false)
                          .allTripsHistoryInformationList[index],
                ),
              );
            },
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(
                  height: 30,
                ),
            itemCount: Provider.of<AppInfor>(context, listen: false)
                .allTripsHistoryInformationList
                .length),
      ),
    );
  }
}
