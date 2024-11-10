import 'package:flutter/material.dart';
import 'package:trippo_app/Assistants/request_assistants.dart';
import 'package:trippo_app/global/global.dart';
import 'package:trippo_app/global/map_key.dart';
import 'package:trippo_app/model/predicted_places.dart';
import 'package:trippo_app/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

 findPlaceAutoCompleteSearch(String inputText) async {
  if (inputText.length > 1) {
    String urlAutoCompleteSearch =
        "https://api.locationiq.com/v1/autocomplete.php?key=pk.b632d7c1eb124b60f9c54e0720159b3e&q=$inputText&format=json";

    var responseAutoCompleteSearch = await RequestAssistants.recalveRequest(urlAutoCompleteSearch);

    if (responseAutoCompleteSearch == "Error Occured. Failed. No Response.") {
      return;
    }

    // Kiểm tra trạng thái
    if (responseAutoCompleteSearch.isNotEmpty) {
      var placePredictionList = (responseAutoCompleteSearch as List)
          .map((jsonData) => PredictedPlaces.fromJson(jsonData))
          .toList();

      setState(() {
        placesPredictedList = placePredictionList;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade400 : buttonColor,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Tìm kiếm địa chỉ của bạn",
            style: TextStyle(color: darkTheme ? Colors.black : Colors.white),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.amber.shade400 : buttonColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.white54,
                      blurRadius: 0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: darkTheme ? Colors.black : Colors.white,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutoCompleteSearch(value);
                              },
                              decoration: InputDecoration(
                                  hintText: 'Tìm kiếm tại đây...',
                                  fillColor:
                                      darkTheme ? Colors.black : Colors.white54,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //Hiển thị địa điểm dự đoán
            (placesPredictedList.length > 0)
                ? Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return PlacePredictiontileDesign(
                            predictedPlaces: placesPredictedList[index],
                          );
                        },
                        physics: ClampingScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 0,
                            color:
                                darkTheme ? Colors.amber.shade400 : Colors.blue,
                            thickness: 0,
                          );
                        },
                        itemCount: placesPredictedList.length),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
