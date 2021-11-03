import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api/manager_data_api.dart';
import '../const/links.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';

enum ProfileDataTime { LastWeek, LastMonth, All }

class EmployeeDataAPI {
  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("EMPLOYEE_DATA_API $functionName $variableName: $data");
  }

  //getting all the attendances from the server by sending the page number
  //by default in the server it s set to 1 if it os not present in the request
  //it return back 10 cards per page
  Future<List<AttendanceInfo>> fetchAttendance([int pageNumber = 1]) async {
    try {
      //creating the request link with the page number parameter
      final Uri attendanceLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_attendance_getter,
        {
          "page": pageNumber.toString(),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        attendanceLink,
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
      //in this case the request is done correctly and no issue founds
      if (res.statusCode == 200) {
        //extracting the data from the response
        Map<String, dynamic> resData = json.decode(res.body);
        //getting the map which contains our data from the entire data
        List<dynamic> data = resData["data"]["data"];
        //creating the result list to hold our data in the correct format
        List<AttendanceInfo> result = [];
        //passing in each element in the map
        data.forEach((element) {
          //adding the element in the result array and converting the data from
          //json format to the attendance class data format
          result.add(AttendanceInfo.fromJSON(element));
        });
        //returning back the result list
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchClientVisits",
        data: "$error",
      );
      throw error;
    }
  }

  //getting all the client visits that the current user had done from the server by sending the page number
  //by default in the server it s set to 1 if it os not present in the request
  //it return back 10 cards per page
  Future<List<ClientVisitInfo>> fetchClientVisits(int pageNumber) async {
    try {
      //creating the request link with the page number parameter
      final Uri clientVisitsLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_client_visit_getter,
        {
          "page": pageNumber.toString(),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        clientVisitsLink,
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
        //extracting the data from the response body
        Map<String, dynamic> resData = json.decode(res.body);
        //getting the necessary data from the response
        List<dynamic> data = resData["data"]["data"];
        //creating result list
        List<ClientVisitInfo> result = [];
        //passing into each element in the array
        data.forEach((element) {
          //changing the data format to match the app data format
          result.add(ClientVisitInfo.fromJSON(element));
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchClientVisits",
        data: "$error",
      );
      throw error;
    }
  }

  //getting all the permissions that the current user had requested from the server by sending the page number
  //by default in the server it s set to 1 if it os not present in the request
  //it return back 10 cards per page
  Future<List<PermissionInfo>> fetchPermissions(int pageNumber) async {
    try {
      //creating the request link with the page number parameter
      final Uri permissionLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_permission_requests_getter,
        {
          "page": pageNumber.toString(),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        permissionLink,
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
        //extracting the necessary data from the response body
        List<dynamic> data = resData["data"]["data"];
        //creating a list in the ram to hold the response data in the same format used in the app
        List<PermissionInfo> result = [];
        //looping into each element in the response body
        data.forEach((element) {
          //converting and saving the element in the same format used in the app
          result.add(PermissionInfo.fromJSON(element));
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchPermissions",
        data: "$error",
      );
      throw error;
    }
  }

  //getting all the reports that the current user had sent from the server by sending the page number
  //by default in the server it s set to 1 if it os not present in the request
  //it return back 10 cards per page
  Future<List<ReportInfo>> fetchReports(int pageNumber) async {
    try {
      //creating the request link with the page number parameter
      final Uri reportLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_reports_getter,
        {
          "page": pageNumber.toString(),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        reportLink,
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
        //extracting the necessary data from the response body
        List<dynamic> data = resData["data"]["data"];
        //creating a list in the ram to hold the the data as it used in the app
        List<ReportInfo> result = [];
        //looping into each element in the response body
        data.forEach((element) {
          //converting and saving the element in the same format used in the app
          result.add(ReportInfo.fromJSON(element));
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchReports",
        data: "$error",
      );
      throw error;
    }
  }

  //getting all the vacations that the current user had requested from the server by sending the page number
  //by default in the server it s set to 1 if it os not present in the request
  //it return back 10 cards per page
  Future<List<VacationInfo>> fetchVacations(int pageNumber) async {
    try {
      //creating the request link with the page number parameter
      final Uri vacationLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_vacation_getter,
        {
          "page": pageNumber.toString(),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        vacationLink,
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
        //extracting the data from the response body
        List<dynamic> data = resData["data"]["data"];
        //creating a list in the ram to hold the data as it used in the ram
        List<VacationInfo> result = [];
        //looping into each element into the response body
        data.forEach((element) {
          //converting the element in the format as it used in the app
          result.add(VacationInfo.fromJSON(element));
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchVacations",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the notifications from the server
  Future<List<NotificationInfo>> fetchNotification([int pageNumber = 1]) async {
    try {
      Uri link = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_notifications_getter, {
        "page": pageNumber.toString(),
      });
      http.Response res = await http.get(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        // extracting response body
        Map<String, dynamic> resData = json.decode(res.body);
        //extracting the notification's list
        List<dynamic> extractedData = resData["data"];
        //creating a local variable to be returned
        List<NotificationInfo> notifications = [];
        //looping throw the fetched notification list
        for (var notification in extractedData) {
          //adding the notification to the list as an employee notification
          notifications.add(NotificationInfo.employeeFromJSON(notification));
        }
        return notifications;
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
        functionName: "fetchNotification",
        data: "$error",
      );
      throw error;
    }
  }

  //getting the profile data from the server
  Future<List<Map<String, String>>> fetchProfileData(
    DateTime from,
    DateTime to,
  ) async {
    try {
      //creating the request link with the filter parameter
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_profile_data_getter,
        {
          "filter": "filter",
          "from": DateFormat("yyyy-MM-dd").format(from),
          "to": DateFormat("yyyy-MM-dd").format(to),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
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
        //converting the response body
        Map<String, dynamic> resData =
            json.decode(res.body) as Map<String, dynamic>;
        //returning the data as it used in the app
        return [
          {"work": resData["work_days_count"].toString() + " days"},
          {"vacation": resData["vacation_days_count"].toString() + " days"},
          {"absent": (resData["absent_days_count"]).toString() + " days"},
          {"permission": resData["permission_requests_count"].toString()},
          {"report": resData["reports_count"].toString()},
          {
            "delay": (resData["delay_duration_sum"]).toDouble().abs().toString()
          },
          if (resData.containsKey("client_visit_count"))
            {"client_visit": resData["client_visit_count"].toString()},
        ];
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
        functionName: "fetchProfileData",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are getting the available reasons to request a new vacation
  Future<List<Map<String, Object>>> fetchVacationReasons() async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_vacation_reasons_getter);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        permissionTypesLink,
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
        //extracting the necessary data from the response body
        List<dynamic> data = resData["data"];
        //creating a list in the ram to hold the data as it used in the app
        List<Map<String, Object>> result = [];
        //looping into each element in the response body
        data.forEach((element) {
          //adding the element into the list
          result.add({
            "name": element["name"],
            "id": element["id"],
          });
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchVacationReasons",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are getting the available reasons to request a new permission
  Future<List<Map<String, Object>>> fetchPermissionReasons() async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_permission_reasons_getter);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        permissionTypesLink,
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
        //extracting the necessary data from the response body
        List<dynamic> data = resData["data"];
        //creating a list in the ram to hold the extracted data as it used in the app
        List<Map<String, Object>> result = [];
        //looping into each element in the response body
        data.forEach((element) {
          //adding the element in the correct format
          result.add({
            "name": element["name"],
            "id": element["id"],
            "need_time": element["need_time"],
          });
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchPermissionReason",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are using the entire date to get the activity done in that day
  Future<List<Map<String, Map<String, dynamic>?>>?> fetchDayEvents(
    DateTime date,
  ) async {
    try {
      //creating the request link with date parameter
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_day_activity_getter,
        {
          "date": DateFormat("yyyy-MM-dd", "en").format(date),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
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
        //converting the response body
        Map<String, dynamic> resData = json.decode(res.body);
        //extracting the necessary data from the response body
        List<dynamic> list = resData["data"]["data"];
        //creating a list in the ram to hold the data as it used in the app
        List<Map<String, Map<String, dynamic>?>> result = [];
        //passing into each element in the response body
        list.forEach((element) {
          //adding the elements in map format
          result.add(
            {element["type"]: element["entity"]},
          );
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchDayEvents",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are getting the employee attendance in the hole month
  //we are sending the app month and year to be able to change the month
  //so the app can be dynamic
  Future<Map<DateTime, String>> fetchMonthAttendance(DateTime date) async {
    Map<DateTime, String> result = {};
    try {
      //creating the request link with month and year parameters
      final Uri attendanceLink = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_attendance_getter,
        {
          "month": DateFormat("MM").format(date),
          "year": DateFormat("yyyy").format(date),
        },
      );
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.get(
        attendanceLink,
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
        // extracting response body
        Map<String, dynamic> resData = json.decode(res.body);
        //extracting the necessary data from the body
        List<dynamic> data = resData["data"]["data"];
        //creating a list in the memory to  hold the extracted data as it in the app format
        List<AttendanceInfo> list = [];
        //passing into each element in the extracted data
        data.forEach((element) {
          //converting the data from json format into the class format
          list.add(AttendanceInfo.fromJSON(element));
        });
        list.forEach((element) {
          result.putIfAbsent(
              element.date, () => element.delay > 0 ? "delay" : "attend");
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
        //extracting the server response
        var resData = json.decode(res.body);
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchClientVisits",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the permission data from the server by the permission id
  Future<Map<String, dynamic>> getPermissionByID(
    int id, {
    bool getEmployee = false,
  }) async {
    try {
      Uri link = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_permission_by_id_getter + "$id");
      http.Response res = await http.get(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        // extracting response body
        Map<String, dynamic> resData = json.decode(res.body);
        //converting the json data into our class
        PermissionInfo permission = PermissionInfo.fromJSON(resData["data"]);
        //creating a local employee to be returned
        EmployeeInfo employee = EmployeeInfo.empty();
        //checking if the developer want to get back the employee data with the permission id
        //this condition is used to reduce the data usage and the time
        if (getEmployee) {
          //creating a manager api object to access the function that fetch employee data
          ManagerDataAPI _managerDataAPI = ManagerDataAPI();
          //getting the employee data from the server
          employee = await _managerDataAPI
              .fetchEmployeeInfo(resData["data"]["employee_id"]);
        }
        //returning the permission and the employee to the request
        return {
          "permission": permission,
          //returning the employee data in case the function need to get back the employee data
          if (getEmployee) "employee": employee
        };
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
        functionName: "getPermissionByID",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the vacation data from the server using the vacation id
  Future<Map<String, dynamic>> getVacationByID(
    int id, {
    bool getEmployee = false,
  }) async {
    try {
      Uri link = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_vacation_by_id_getter + "$id");
      http.Response res = await http.get(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        // extracting response body
        Map<String, dynamic> resData = json.decode(res.body);
        //converting the json data into the class to use
        VacationInfo vacation = VacationInfo.fromJSON(resData["data"]);
        //creating a local employee to be returned
        EmployeeInfo employee = EmployeeInfo.empty();
        //checking if the developer want to get back the employee data with the permission id
        //this condition is used to reduce the data usage and the time
        if (getEmployee) {
          //creating a manager api object to access the function that fetch employee data
          ManagerDataAPI _managerDataAPI = ManagerDataAPI();
          //getting the employee data from the server
          employee = await _managerDataAPI
              .fetchEmployeeInfo(resData["data"]["employee_id"]);
        }
        //returning the vacation and the employee to the request
        return {
          "vacation": vacation,
          //returning the employee data in case the function need to get back the employee data
          if (getEmployee) "employee": employee
        };
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
        functionName: "getVacationByID",
        data: "$error",
      );
      throw error;
    }
  }

  //updating the profile picture
  //if the file is null the picture will be reset to the profile avatar
  Future<void> updateProfilePicture(File? image) async {
    try {
      Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.employee_update_profile_picture,
      );
      //creating the request
      http.MultipartRequest request = http.MultipartRequest("POST", link)
        //the response data format
        ..headers["Accept"] = ServerConstants.response_format
        //the response language
        ..headers["X-localization"] =
            Get.find<AppLocalizationController>().currentLocale.languageCode
        //sending the authentication key to get the exact employee data
        ..headers["Authorization"] =
            "Bearer ${Get.find<LoginController>().tokenid}";
      //sending the report file if exist
      if (image != null) {
        //sending the request
        final http.StreamedResponse res = await request.send();
        //in this case the request had completed successfully
        if (res.statusCode == 200) {
          await Get.find<LoginController>().flushUserData();
          //parsing the response to a understandable one so we can extract the server error message
          final http.Response resData = await http.Response.fromStream(res);
          //extracting and throwing back the error message
          throw json.decode(resData.body)["message"];
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
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "updateProfilePicture",
        data: "$error",
      );
      throw error;
    }
  }
}
