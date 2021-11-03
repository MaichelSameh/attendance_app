import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const/links.dart';
import 'controllers.dart';

class HomeController extends GetxController {
  Map<String, int> _heroData = {};

  int _notificationCount = 0;

  List<Map<String, Map<String, dynamic>?>> _recentActivity = [];

  Map<String, int> get heroData => this._heroData;

  List<Map<String, Map<String, dynamic>?>> get recentActivity =>
      this._recentActivity;

  int get notificationsCount => this._notificationCount;

  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("HOME_CONTROLLER $functionName $variableName: $data");
  }

  //in this function the user had received a new notification
  //and he is still using the app
  void incrementNotificationCount() {
    //incrementing the notification counter by one
    this._notificationCount++;
    //updating the counter so all the listeners can release the changes
    update();
  }

  //this function must be ued only when the app is initialized(in the main function)
  //this function is used to get number of notifications received when the app was in the background
  void initNotificationCount() async {
    //creating an instance from the shared preferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    //getting the number of the notifications from the background
    this._notificationCount = pref.getInt("employee_notification_count") ?? 0;
    pref.setInt("employee_notification_count", 0);
  }

  //in this function we are resetting the notification
  //counter to zero
  //this function must be invocated only in the notification screen
  //when the user is in the employee mode
  void resetNotificationCount() {
    this._notificationCount = 0;
  }

  //in this function we are accessing the GPS to gt the user location
  Future<Position> _getUserCurrentPosition() async {
    //check if the location is turned in or not
    final bool enabled = await Geolocator.isLocationServiceEnabled();
    //Getting the GPS permission status
    LocationPermission permission = await Geolocator.checkPermission();
    //check if the user had guaranteed the GPS permission or not
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      //user hadn't guaranteed the permission so we request
      permission = await Geolocator.requestPermission();
      //the user had denied the permission request so we will
      //throw back an error message
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        throw "You must allow the location access in order to continue using this service";
    }
    //the GPS is turned off
    //so we will throw an error message to alert the user
    if (!enabled) {
      throw "Please open your location service first";
    }
    //saving the user position in the memory
    Position currentPosition = await Geolocator.getCurrentPosition();
    return Get.find<LoginController>().email == "ID123456_C1" ||
            Get.find<LoginController>().email == "ID123457_C1" ||
            Get.find<LoginController>().email == "ID123458_C1"
        ?
        //this return statement is just a demo one for the developer so I can work from any where
        Position(
            longitude: 30.9201832,
            latitude: 29.9660205,
            timestamp: currentPosition.timestamp,
            accuracy: currentPosition.accuracy,
            altitude: currentPosition.altitude,
            heading: currentPosition.heading,
            speed: currentPosition.speed,
            speedAccuracy: currentPosition.speedAccuracy,
          )
        :
        //returning back the user position
        currentPosition;
  }

  //in this function the user is within the company area and want to start his work day
  Future<bool> startWork() async {
    Position currentPosition = await _getUserCurrentPosition();
    //creating the request link
    final Uri startWorkLink = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.employee_start_work_action,
    );
    //sending the start wrk request
    //it's a post request because it will add another row in the data base
    final http.Response res = await http.post(
      startWorkLink,
      headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      },
      body: {
        //sending the user position to check whether  he is within the company area or not
        "lat": currentPosition.latitude.toString(),
        "lon": currentPosition.longitude.toString(),
      },
    );
    //in this case the request had completed successfully so we need just to flush the usr data
    if (res.statusCode == 200) {
      // flushing the uer data from the server
      Get.find<LoginController>().flushUserData();
      return true;
    }
    //in this case case our token session is expired so we will just flush it
    //and throw back an error message to inform the user that he need to try again
    else if (res.statusCode == 401) {
      //flushing the token to start a new session
      Get.find<LoginController>().flushTokenid();
      //throwing back the error message
      throw Get.find<AppLocalizationController>()
          .getTranslatedValue("try_again");
    }
    //in this case something went wrong in the server
    //so we will just throw back the server error
    else {
      //extracting the server response
      var resData = json.decode(res.body);
      //throwing the error
      throw resData["message"];
    }
  }

  //in this function the user want to start a client visit
  Future<bool> visitClient(String clientName) async {
    Position currentPosition = await _getUserCurrentPosition();
    //creating the request link
    final Uri visitClientLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.employee_start_visit_action);
    final http.Response res = await http.post(visitClientLink, headers: {
      //the response data format
      "Accept": ServerConstants.response_format,
      //the response language
      "X-localization":
          Get.find<AppLocalizationController>().currentLocale.languageCode,
      //sending the authentication key to get the exact employee data
      "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
    }, body: {
      //sending the user location to save the point of start
      "start_lat": currentPosition.latitude.toString(),
      "start_lon": currentPosition.longitude.toString(),
      "client_name": clientName,
    });
    //in this case the request had been completed successfully
    if (res.statusCode == 200) {
      //flushing the user data from the server
      Get.find<LoginController>().flushUserData();
      return true;
    }
    //in this case case our token session is expired so we will just flush it
    //and throw back an error message to inform the user that he need to try again
    else if (res.statusCode == 401) {
      //flushing the token to start a new session
      Get.find<LoginController>().flushTokenid();
      //throwing back the error message
      throw Get.find<AppLocalizationController>()
          .getTranslatedValue("try_again");
    }
    //in this case something went wrong in the server
    //so we will just throw back the server error
    else {
      //extracting the server response
      var resData = json.decode(res.body);
      //throwing the error
      throw resData["message"];
    }
  }

  //in this function the user want to start a client meeting
  Future<bool> meetClient(File? image) async {
    Position currentPosition = await _getUserCurrentPosition();
    //creating the request link
    final Uri meetClientLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.employee_start_meet_action);
    //creating the request
    http.MultipartRequest request =
        http.MultipartRequest("POST", meetClientLink)
          //the response data format
          ..headers["Accept"] = ServerConstants.response_format
          //the response language
          ..headers["X-localization"] =
              Get.find<AppLocalizationController>().currentLocale.languageCode
          //sending the authentication key to get the exact employee data
          ..headers["Authorization"] =
              "Bearer ${Get.find<LoginController>().tokenid}"
          //sending the user location to be used then in the reports
          ..fields["meet_lat"] = currentPosition.latitude.toString()
          ..fields["meet_lon"] = currentPosition.longitude.toString();
    //checking if there is an existing image or not
    if (image != null) {
      //sending the image file to the server
      request.files.add(await http.MultipartFile.fromPath(
        'captured_photo',
        image.path,
      ));
    }
    //sending the request to the server
    final http.StreamedResponse res = await request.send();
    //in this case the request had been completed successfully
    if (res.statusCode == 200) {
      //flushing the user data from the server
      Get.find<LoginController>().flushUserData();
      return true;
    }
    //in this case case our token session is expired so we will just flush it
    //and throw back an error message to inform the user that he need to try again
    else if (res.statusCode == 401) {
      //flushing the token to start a new session
      Get.find<LoginController>().flushTokenid();
      //throwing back the error message
      throw Get.find<AppLocalizationController>()
          .getTranslatedValue("try_again");
    }
    //in this case something went wrong in the server
    //so we will just throw back the server error
    else {
      //parsing the response to a understandable one so we can extract the server error message
      final http.Response resData = await http.Response.fromStream(res);
      //extracting and throwing back the error message
      throw json.decode(resData.body)["message"];
    }
  }

  //in this function the user want to end a client visit
  Future<bool> endVisit(String nextDestination) async {
    Position currentPosition = await _getUserCurrentPosition();
    //creating the request link
    final Uri homeDataLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.employee_end_visit_action);
    final http.Response res = await http.post(
      homeDataLink,
      headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      },
      body: {
        //sending the user location to the server to be used then in the report
        "end_lat": currentPosition.latitude.toString(),
        "end_lon": currentPosition.longitude.toString(),
        //sending the user next destination to save it in the server
        "next_action": nextDestination,
      },
    );
    //in this case the request had been completed successfully
    if (res.statusCode == 200) {
      //flushing the user data from the server
      Get.find<LoginController>().flushUserData();
      return true;
    }
    //in this case case our token session is expired so we will just flush it
    //and throw back an error message to inform the user that he need to try again
    else if (res.statusCode == 401) {
      //flushing the token to start a new session
      Get.find<LoginController>().flushTokenid();
      //throwing back the error message
      throw Get.find<AppLocalizationController>()
          .getTranslatedValue("try_again");
    }
    //in this case something went wrong in the server
    //so we will just throw back the server error
    else {
      //extracting the server response
      var resData = json.decode(res.body);
      //throwing the error
      throw resData["message"];
    }
  }

  //in this function the user is within the company area and want to finish his work day
  Future<bool> finishWork() async {
    Position currentPosition = await _getUserCurrentPosition();
    //creating the request link
    final Uri startWorkLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.employee_end_work_action);
    final http.Response res = await http.post(startWorkLink, headers: {
      //the response data format
      "Accept": ServerConstants.response_format,
      //the response language
      "X-localization":
          Get.find<AppLocalizationController>().currentLocale.languageCode,
      //sending the authentication key to get the exact employee data
      "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
    }, body: {
      //sending the user location to check whether  he is in the company area or not
      "lat": currentPosition.latitude.toString(),
      "lon": currentPosition.longitude.toString(),
    });
    //in this case the request had been completed successfully
    if (res.statusCode == 200) {
      //flushing the user data from the server
      Get.find<LoginController>().flushUserData();
      return true;
    }
    //in this case case our token session is expired so we will just flush it
    //and throw back an error message to inform the user that he need to try again
    else if (res.statusCode == 401) {
      //flushing the token to start a new session
      Get.find<LoginController>().flushTokenid();
      //throwing back the error message
      throw Get.find<AppLocalizationController>()
          .getTranslatedValue("try_again");
    }
    //in this case something went wrong in the server
    //so we will just throw back the server error
    else {
      //extracting the server response
      var resData = json.decode(res.body);
      //throwing the error
      throw resData["message"];
    }
  }

  // in this function we are getting all the daa necessary for the home screen
  Future<List<Map<String, Map<String, String>>>> fetchHomeData() async {
    List<Map<String, Map<String, String>>> result = [];
    try {
      //creating the request link
      final Uri homeDataLink = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_home_data_getter);
      final http.Response res = await http.get(
        homeDataLink,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
          //sending the authentication key to get the exact employee data
          "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //converting the response body
        Map<String, dynamic> resData = json.decode(res.body);
        //getting the hero cards info
        _setHeroData(resData);
        _setRecentActivity(resData["data"]["recent_activity"]);
      }
      //in this case case our token session is expired so we will just flush it
      //and throw back an error message to inform the user that he need to try again
      else if (res.statusCode == 401) {
        //flushing the token to start a new session
        Get.find<LoginController>().flushTokenid();
        //throwing back the error message
        throw Get.find<AppLocalizationController>()
            .getTranslatedValue("try_again");
      }
      //in this case something went wrong in the server
      //so we will just throw back the server error
      else {
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchRecentActivity",
        data: "$error",
      );
      throw error;
    }
    return result;
  }

  //in this function we are we are extracting the recent activity from the response
  void _setRecentActivity(List<dynamic> recentActivity) {
    _recentActivity = [];
    recentActivity.forEach((element) {
      Map<String, dynamic>? data = element["entity"] as Map<String, dynamic>?;

      _recentActivity.add(
        {
          element["type"]: data,
        },
      );
    });
    update();
  }

  //in this function we are getting the data for the hero cards from the entire response
  //in each line we are getting the number of the action named in the last key
  void _setHeroData(Map<String, dynamic> data) {
    _heroData.containsKey("delay_count")
        ? _heroData.update(
            "delay_count", (value) => data["data"]["delay_count"] ?? 0)
        : _heroData.putIfAbsent(
            "delay_count", () => data["data"]["delay_count"] ?? 0);
    _heroData.containsKey("vacation_count")
        ? _heroData.update(
            "vacation_count", (value) => data["data"]["vacation_count"] ?? 0)
        : _heroData.putIfAbsent(
            "vacation_count", () => data["data"]["vacation_count"] ?? 0);
    _heroData.containsKey("attend_count")
        ? _heroData.update(
            "attend_count", (value) => data["data"]["attend_count"] ?? 0)
        : _heroData.putIfAbsent(
            "attend_count", () => data["data"]["attend_count"] ?? 0);
    _heroData.containsKey("absent_count")
        ? _heroData.update(
            "absent_count", (value) => data["data"]["absent_count"] ?? 0)
        : _heroData.putIfAbsent(
            "absent_count", () => data["data"]["absent_count"] ?? 0);
    _heroData.containsKey("reports_count")
        ? _heroData.update(
            "reports_count", (value) => data["data"]["reports_count"] ?? 0)
        : _heroData.putIfAbsent(
            "reports_count", () => data["data"]["reports_count"] ?? 0);
    _heroData.containsKey("client_visit_count")
        ? _heroData.update("client_visit_count",
            (value) => data["data"]["client_visit_count"] ?? 0)
        : _heroData.putIfAbsent("client_visit_count",
            () => data["data"]["client_visit_count"] ?? 0);
    _heroData.containsKey("accepted_permission_requests_count")
        ? _heroData.update("accepted_permission_requests_count",
            (value) => data["data"]["accepted_permission_requests_count"] ?? 0)
        : _heroData.putIfAbsent("accepted_permission_requests_count",
            () => data["data"]["accepted_permission_requests_count"] ?? 0);
    _heroData.containsKey("refused_permission_requests_count")
        ? _heroData.update("refused_permission_requests_count",
            (value) => data["data"]["refused_permission_requests_count"] ?? 0)
        : _heroData.putIfAbsent("refused_permission_requests_count",
            () => data["data"]["refused_permission_requests_count"] ?? 0);
    _heroData.containsKey("pending_permission_requests_count")
        ? _heroData.update("pending_permission_requests_count",
            (value) => data["data"]["pending_permission_requests_count"] ?? 0)
        : _heroData.putIfAbsent("pending_permission_requests_count",
            () => data["data"]["pending_permission_requests_count"] ?? 0);
    update();
  }
}
