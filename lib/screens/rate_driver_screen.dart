import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/splashScreen/splash_screen.dart';

class RateDriverScreen extends StatefulWidget {
  RateDriverScreen({super.key, this.assignedDriverId});

  String? assignedDriverId;

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();

}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countRatingStars = 0.0;
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
            color: darkTheme ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
            ),
            Text(
              "Rate Trip Experience",
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            SizedBox(
              height: 20,
            ),
            SmoothStarRating(
              rating: countRatingStars,
              allowHalfRating: false,
              starCount: 5,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              borderColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
              size: 40,
              onRatingChanged: (valueOfStarsChanged) {
                setState(() {
                  countRatingStars = valueOfStarsChanged
                      .toDouble(); // Cập nhật biến countRatingStars
                  if (valueOfStarsChanged == 1) {
                    titleStarsRating = "very bad";
                  } else if (valueOfStarsChanged == 2) {
                    titleStarsRating = "bad";
                  } else if (valueOfStarsChanged == 3) {
                    titleStarsRating = "Good";
                  } else if (valueOfStarsChanged == 4) {
                    titleStarsRating = "very good";
                  } else if (valueOfStarsChanged == 5) {
                    titleStarsRating = "Excellent";
                  }
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              titleStarsRating,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                DatabaseReference rateDriverRef = FirebaseDatabase.instance
                    .ref()
                    .child("drivers")
                    .child(widget.assignedDriverId!)
                    .child("ratings");

                rateDriverRef.once().then((snap) {
                  if (snap.snapshot.value == null) {
                    rateDriverRef.set(countRatingStars.toString());

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ),
                    );
                  } else {
                    double pastRatings =
                        double.parse(snap.snapshot.value.toString());
                    double newAverageRatings =
                        (pastRatings + countRatingStars) / 2;
                    rateDriverRef.set(newAverageRatings.toString());
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ),
                    );
                  }
                
                  Fluttertoast.showToast(
                      msg: "Vui lòng khởi động lại ứng dụng ngay bây giờ!");
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    darkTheme ? Colors.amber.shade400 : Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 70),
              ),
              child: Text(
                "Submit",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.black : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
