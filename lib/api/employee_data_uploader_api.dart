import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/models/models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../const/links.dart';
import '../controllers/controllers.dart';
import '../models/client_visit_info.dart';

class EmployeeDataUploaderAPI {
  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("EMPLOYEE_DATA_UPLOADER_API $functionName $variableName: $data");
  }

  //in this function we are accessing the GPS to gt the user location
  Future<Position> getUserCurrentPosition() async {
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
    //this return statement is just a demo one for the developer so I can work from any where
    //returning back the user position
    return currentPosition;
  }

  //in this function the user want to send a new report to the server
  Future<ReportInfo> addReport(
    String title,
    String description, {
    File? file,
    String id = "",
    bool edit = false,
  }) async {
    try {
      //creating the request link
      final Uri addReportLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_report_uploader + (edit ? "/$id/update" : ""),
      );
      //creating the request
      http.MultipartRequest request =
          http.MultipartRequest("POST", addReportLink)
            //the response data format
            ..headers["Accept"] = ServerConstants.response_format
            //the response language
            ..headers["X-localization"] =
                Get.find<AppLocalizationController>().currentLocale.languageCode
            //sending the authentication key to get the exact employee data
            ..headers["Authorization"] =
                "Bearer ${Get.find<LoginController>().tokenid}"
            //sending the report title
            ..fields["title"] = title
            //sending the report title
            ..fields["description"] = description;
      //deciding if this request going to override an existing report or not
      if (edit) {
        request.fields["_method"] = "patch";
      }
      //sending the report file if exist
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'attached_file',
          file.path,
        ));
      }
      //sending the request
      final http.StreamedResponse res = await request.send();
      //in this case the request had completed successfully
      if (res.statusCode == 200) {
        final http.Response resData = await http.Response.fromStream(res);
        Map<String, dynamic> data = json.decode(resData.body);
        return ReportInfo.fromJSON(data["data"]);
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "addReport",
        data: error.toString(),
      );
      throw error;
    }
  }

  //in this function the user want to request a new vacation to the server
  Future<bool> requestVacation(
    String vacationID,
    DateTime fromDate,
    DateTime toDate,
    String description, [
    String id = "",
    bool edit = false,
  ]) async {
    try {
      //creating the request link
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_vacation_request + (edit ? "/$id/update" : ""),
      );
      // creating and sending the request
      final http.Response res = await http.post(
        link,
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
          //sending the vacation reason
          "vacations_type_id": vacationID,
          //sending the vacation start date
          "from": DateFormat("yyyy-MM-dd", "en").format(fromDate),
          //sending the vacation end date
          "to": DateFormat("yyyy-MM-dd", "en").format(toDate),
          //sending the vacation description
          "description": description,
          //deciding whether  this request is going to override an existing vacation or not
          if (edit) "_method": "patch",
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "requestVacation",
        data: error.toString(),
      );
      throw error;
    }
  }

  //in this function the user want to request a new permission to the server
  Future<bool> requestPermission(
    String permissionID,
    DateTime date,
    String description, [
    String id = "",
    bool edit = false,
  ]) async {
    try {
      //creating the request link
      final Uri requestPermissionLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_permission_request +
            (edit ? "/$id/update" : ""),
      );
      //creating and sending the request
      final http.Response res = await http.post(
        requestPermissionLink,
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
          //sending the permission reason
          "permissions_type_id": permissionID,
          //sending the permission start date
          "from": DateFormat("yyyy-MM-dd", "en").format(date),
          //sending the permission end date
          "to": DateFormat("yyyy-MM-dd", "en").format(date),
          //sending the permission time
          "time": DateFormat("hh:mm:ss", "en").format(date),
          //sending the permission description
          "description": description,
          //deciding whether  this request is going to override an existing permission or not
          if (edit) "_method": "patch",
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "addPermission",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function the user want to delete a report from the server
  Future<bool> deleteReport(String id) async {
    try {
      //creating the request link
      final Uri deleteReportLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_report_uploader + "/$id",
      );
      //creating and sending the delete request
      http.Response res = await http.delete(
        deleteReportLink,
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "deleteReport",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function the user want to delete a vacation from the server
  Future<bool> deleteVacation(String id) async {
    try {
      //creating the request link
      final Uri deleteVacationLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_vacation_request + "/$id",
      );
      //creating and saving the delete request
      http.Response res = await http.delete(
        deleteVacationLink,
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "deleteVacation",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function the user want to delete a permission from the server
  Future<bool> deletePermission(String id) async {
    try {
      //creating the request link
      final Uri deletePermissionLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_permission_request + "/$id",
      );
      //creating and sending the delete request
      http.Response res = await http.delete(
        deletePermissionLink,
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "deletePermission",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are checking if the current user can add a new location or not
  Future<bool> canAddBranch() async {
    try {
      //creating the request link
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_can_add_branch_getter,
      );
      //creating and sending the delete request
      http.Response res = await http.get(
        link,
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
        //extracting the response data
        Map<String, dynamic> resData = json.decode(res.body);
        //returning if the current user can add a branch or not
        return resData["data"]["can_add_new_branch"].toString() == "1";
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
        functionName: "canAddBranch",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function user are adding new branch to the company system
  Future<void> addNewBranch({
    required String name,
    required String phoneNumber,
    required String latitude,
    required String longitude,
  }) async {
    try {
      //creating the request link
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_add_branch_request,
      );

      //creating and sending the delete request
      http.Response res = await http.post(
        link,
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
          "lat": latitude,
          "lon": longitude,
          "phone": phoneNumber,
          "name": name,
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        return;
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
        functionName: "addNewBranch",
        data: "$error",
      );
      throw error;
    }
  }

  //searching about a user by his name
  Future<List<ClientVisitInfo>> searchClientVisits(String clientName) async {
    //declaring the employees URL
    Uri link = Uri.https(ServerConstants.server_base_link,
        ServerConstants.employee_search_client_visits_request + "/$clientName");
    try {
      //executing the employee get link
      http.Response res = await http.get(
        link,
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
        //extracting the response body
        dynamic resData = json.decode(res.body);
        //extracting the required data
        List<dynamic> data = resData["data"][0]["data"];
        //creating a variable to hold all the data until return it
        List<ClientVisitInfo> result = [];
        //looping throw the data fetched from the server
        data.forEach((element) async {
          //getting the employee info from the fetched data
          ClientVisitInfo visit = ClientVisitInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(visit);
          // returning the fetched data after the formatting process
        });
        return result;
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
        //extracting the response body
        dynamic resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "searchClientVisits",
        data: "$error",
      );
      throw error;
    }
  }
}
