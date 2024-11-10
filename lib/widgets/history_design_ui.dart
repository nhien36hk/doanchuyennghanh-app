import 'package:drivers_android/global/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drivers_android/model/trips_history_model.dart';

class HistoryDesignUi extends StatefulWidget {
  HistoryDesignUi({super.key, this.tripsHistoryModel});

  TripsHistoryModel? tripsHistoryModel;

  @override
  State<HistoryDesignUi> createState() => _HistoryDesignUiState();
}

class _HistoryDesignUiState extends State<HistoryDesignUi> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    String formatDateAndTime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formatDateAndTime;
  }

  @override
  Widget build(BuildContext context) {
     bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateAndTime(widget.tripsHistoryModel!.time!),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: darkTheme ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tripsHistoryModel!.driverName!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(double.parse(widget.tripsHistoryModel!.ratings!).toStringAsFixed(2)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(width: 50,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tổng tiền",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${widget.tripsHistoryModel!.fareAmount!}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trạng thái",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${widget.tripsHistoryModel!.status! == "ended" ? "Hoàn thành" : "Chưa hoàn thành"}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 3,
                  color: Colors.grey[100],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Địa chỉ thu gom",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "${widget.tripsHistoryModel!.originAddress!}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
