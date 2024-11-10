import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trippo_app/Assistants/request_assistants.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/global/map_key.dart';
import 'package:trippo_app/inforHandler/app_infor.dart';
import 'package:trippo_app/model/direction.dart';
import 'package:trippo_app/model/predicted_places.dart';
import 'package:trippo_app/widgets/progress_dialog.dart';

class PlacePredictiontileDesign extends StatefulWidget {
  const PlacePredictiontileDesign({this.predictedPlaces});

  final PredictedPlaces? predictedPlaces;

  @override
  State<PlacePredictiontileDesign> createState() =>
      _PlacePredictiontileDesignState();
}

class _PlacePredictiontileDesignState extends State<PlacePredictiontileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    print("Showing dialog");
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: 'Setting up Drop-off. Please wait...',
      ),
    );

    // Thêm một thời gian ngắn để hiển thị dialog
    await Future.delayed(Duration(seconds: 1));
    Navigator.of(context).pop(); // Để xem dialog xuất hiện
    Direction direction = Direction();
    direction.locationName = widget.predictedPlaces!.main_text;
    direction.humanReadableAddress = widget.predictedPlaces!.secondary_text;
    direction.locationId =
        widget.predictedPlaces!.place_id; // Cập nhật locationId
    direction.locationLatitude =
        widget.predictedPlaces!.locationLatitude; // Cập nhật latitude
    direction.locationLongtitude =
        widget.predictedPlaces!.locationLongitude; // Cập nhật longitude

    // Cập nhật địa chỉ trong provider
    Provider.of<AppInfor>(context, listen: false)
        .updatePickUpLocationAddress(direction);

    // Cập nhật giá trị địa chỉ trong biến global
    userDropOffAddress = direction.locationName!;

    // Đóng dialog
    if (mounted) {
      Navigator.pop(context, "obtainedDropoff");
    } // Đảm bảo bạn đang đóng dialog đã hiển thị

    print("Dialog closed");
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade400 : buttonColor,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.predictedPlaces!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      fontSize: 16),
                ),
                Text(
                  widget.predictedPlaces!.secondary_text!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      fontSize: 16),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
