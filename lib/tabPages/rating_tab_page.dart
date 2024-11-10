import 'package:drivers_android/Assistants/assistants_method.dart';
import 'package:drivers_android/global/global.dart';
import 'package:drivers_android/inforHandler/app_infor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class RatingTabPage extends StatefulWidget {
  const RatingTabPage({super.key});

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {
  double ratingsNumber = 0;
  String titleStarsRating = "";
  late Future<void> _driverRatingsFuture;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: darkTheme ? Colors.grey : Colors.white60,
        child: Container(
          margin: EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22),
              Text(
                "Số sao của bạn",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.amber.shade400 : buttonColor,
                ),
              ),
              SizedBox(height: 20),
              SmoothStarRating(
                rating: double.parse(
                    Provider.of<AppInfor>(context, listen: false)
                        .driverAverageRatings),
                allowHalfRating: true,
                starCount: 5,
                color: Colors.orange,
                borderColor: Colors.orange,
                size: 46,
              ),
              SizedBox(height: 12),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
