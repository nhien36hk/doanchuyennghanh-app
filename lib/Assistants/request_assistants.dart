import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistants {
  static Future<dynamic> recalveRequest(String url) async {
    try {
      http.Response httpResponse = await http.get(Uri.parse(url));

      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      } else {
        print("Error: Received status code ${httpResponse.statusCode}");
        return "Error Occurred. Failed. No Response.";
      }
    } catch (exp) {
      print("Exception occurred: $exp");
      return "Error Occurred. Failed. No Response.";
    }
  }
}
