import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const/links.dart';
import '../models/models.dart';
import 'controllers.dart';

class ManagerHomeController extends GetxController {
  int _acceptedPermissions = 0;
  int _attendedEmployee = 0;
  int _absentEmployee = 0;
  int _delayedEmployee = 0;
  int _inVacationEmployee = 0;
  int _employeesCount = 0;
  int _notificationCount = 0;

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _reports = [];

  int get acceptedPermission => this._acceptedPermissions;
  int get attendedEmployee => this._attendedEmployee;
  int get absentEmployee => this._absentEmployee;
  int get delayedEmployee => this._delayedEmployee;
  int get inVacationEmployee => this._inVacationEmployee;
  int get employeesCount => this._employeesCount;
  int get notificationsCount => this._notificationCount;

  List<Map<String, dynamic>> get pendingRequests => this._pendingRequests;
  List<Map<String, dynamic>> get newReports => this._reports;

  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("MANAGER_HOME_CONTROLLER $functionName $variableName: $data");
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
    this._notificationCount = pref.getInt("manager_notification_count") ?? 0;
    pref.setInt("manager_notification_count", 0);
  }

  //in this function we are resetting the notification
  //counter to zero
  //this function must be invocated only in the notification screen
  //when the user is in the manager mode
  void resetNotificationCount() {
    this._notificationCount = 0;
    update();
  }

  double getPercent(int count) {
    // return count / this.employeesCount;
    return count / employeesCount;
  }

  //in this function we are getting the cards data from the server (which is only numbers)
  Future<void> cardsData() async {
    //the URL for the permissions count that is going to be executed in the current(bishoy) date
    Uri permissionsLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.manager_accepted_permissions_count_getter);
    //the URL for the attendance of the employee in this date should return the number of absent, delayed, in vacation and absent
    Uri attendanceLink = Uri.https(ServerConstants.server_base_link,
        ServerConstants.manager_employees_status_count_getter);
    try {
      //executing the permissions url
      http.Response permissionResponse = await http.get(
        permissionsLink,
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
      //executing the attendance url
      http.Response attendanceResponse = await http.get(
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
      //in this case the permission request had been completed successfully
      if (permissionResponse.statusCode == 200) {
        //extracting the body data
        Map<String, dynamic> resData = json.decode(permissionResponse.body);
        //getting the number of the permission to be executed
        this._acceptedPermissions =
            resData["data"]["Accepted_permission_count"];
        update();
      }
      //in this case case our token session is expired so we will just flush it
      //and throw back an error message to inform the user that he need to try again
      else if (permissionResponse.statusCode == 401) {
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
        var resData = json.decode(permissionResponse.body);
        //throwing the error
        throw resData["message"];
      }

      //in this case the attendance request had been completed successfully
      if (attendanceResponse.statusCode == 200) {
        //extracting the response data
        Map<String, dynamic> resData = json.decode(attendanceResponse.body);
        //getting the attended employee number
        this._attendedEmployee = resData["data"]["count_attend"];
        //getting the delayed employees number
        this._delayedEmployee = resData["data"]["count_delay"];
        //getting the department employees count
        this._employeesCount = resData["data"]["all_employees"];
        //getting the vacationed employee number
        this._inVacationEmployee = resData["data"]["count_vacation"];
        //getting the absent employee number
        this._absentEmployee = this._employeesCount -
            (this._attendedEmployee +
                this._attendedEmployee +
                this._inVacationEmployee);
        update();
      }
      //in this case case our token session is expired so we will just flush it
      //and throw back an error message to inform the user that he need to try again
      else if (attendanceResponse.statusCode == 401) {
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
        var resData = json.decode(attendanceResponse.body);
        //throwing the error
        throw resData["message"];
      }
      update();
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "cardsData",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the employee information by the id to use it with the other data
  Future<EmployeeInfo> _fetchEmployeeInfo(int id) async {
    //declaring the employee info getter link
    Uri link = Uri.https(ServerConstants.server_base_link,
        ServerConstants.manager_employee_info_request + "/$id");
    try {
      //executing the getter link
      http.Response res = await http.get(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      if (res.statusCode == 200) {
        //extracting the response body
        Map<String, dynamic> resData = json.decode(res.body);
        return EmployeeInfo.fromJSON(resData["data"]);
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
        functionName: "_fetchEmployeeInfo",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are fetching the pending requests (vacations or permissions)
  Future<void> fetchPendingRequests([int page = 1]) async {
    //defining the pending permissions getter URI
    Uri pendingPermissionsLink = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_get_pending_permissions,
      {
        "page": page.toString(),
      },
    );
    //defining the pending vacations getter URI
    Uri pendingVacationsLink = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_get_pending_vacations,
      {
        "page": page.toString(),
      },
    );
    //creating a variable to hold all the data until return it
    Map<String, EmployeeInfo> employees = {};
    try {
      //executing the pending permissions request
      http.Response permissionResponse = await http.get(
        pendingPermissionsLink,
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
      //executing the pending vacation request
      http.Response vacationResponse = await http.get(
        pendingVacationsLink,
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
      Map<String, dynamic> permissionData =
          json.decode(permissionResponse.body);
      Map<String, dynamic> vacationData = json.decode(vacationResponse.body);
      _pendingRequests.clear();
      update();
      //in this case the permissions request had been completed successfully
      if (permissionResponse.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = permissionData["data"];
        //looping throw the data fetched from the server
        data.forEach(
          (element) async {
            //checking if we had already fetched this user before
            //this condition is used to reduce the requests sent to get employee
            //data
            if (!employees.containsKey(element["employee_id"])) {
              //getting the user data from his id
              EmployeeInfo employee =
                  await _fetchEmployeeInfo(int.parse(element["employee_id"]));
              employees.putIfAbsent(element["employee_id"], () => employee);
            }
            //getting the client visit info from the fetched data
            PermissionInfo permission = PermissionInfo.fromJSON(element);
            //adding the event info with the user data
            _pendingRequests.add(
              {
                //getting the employee data from the employee map by its id
                "employee": employees[element["employee_id"]],
                "permission": permission,
              },
            );
            update();
          },
        );
      }
      //in this case case our token session is expired so we will just flush it
      //and throw back an error message to inform the user that he need to try again
      else if (permissionResponse.statusCode == 401) {
        //flushing the token to start a new session
        Get.find<LoginController>().flushTokenid();
        //throwing back the error message
        throw Get.find<AppLocalizationController>()
            .getTranslatedValue("try_again");
      }
      //in this case something went wrong in the server
      //so we will just throw back the server error
      else {
        //throwing the error
        throw permissionData["message"];
      }
      //in this case the vacations request had been completed successfully
      if (vacationResponse.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = vacationData["data"];
        //looping throw the data fetched from the server
        data.forEach(
          (element) async {
            //checking if we had already fetched this user before
            //this condition is used to reduce the requests sent to get employee
            //data
            if (!employees.containsKey(element["employee_id"])) {
              //getting the user data from his id
              EmployeeInfo employee =
                  await _fetchEmployeeInfo(int.parse(element["employee_id"]));
              employees.putIfAbsent(element["employee_id"], () => employee);
            }
            //getting the client visit info from the fetched data
            VacationInfo vacation = VacationInfo.fromJSON(element);
            //adding the event info with the user data
            _pendingRequests.add(
              {
                //getting the employee data from the employee map by its id
                "employee": employees[element["employee_id"]],
                "vacation": vacation,
              },
            );
            _pendingRequests.shuffle();
            update();
          },
        );
      }
      //in this case case our token session is expired so we will just flush it
      //and throw back an error message to inform the user that he need to try again
      else if (vacationResponse.statusCode == 401) {
        //flushing the token to start a new session
        Get.find<LoginController>().flushTokenid();
        //throwing back the error message
        throw Get.find<AppLocalizationController>()
            .getTranslatedValue("try_again");
      }
      //in this case something went wrong in the server
      //so we will just throw back the server error
      else {
        //throwing the error
        throw vacationData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchPendingRequests",
        data: "$error",
      );
      throw error;
    }
  }

  // in this function we are fetching the new reports that are created in the current day
  Future<void> fetchNewReports([int page = 1]) async {
    //declaring the reports link
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_todays_reports_request,
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the reports request
      http.Response res = await http.get(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      //extracting the response body
      Map<String, dynamic> resData = json.decode(res.body);
      if (res.statusCode == 200) {
        _reports.clear();
        update();
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        data.forEach(
          (element) async {
            //checking if we had already fetched this user before
            //this condition is used to reduce the requests sent to get employee
            //data
            if (!employees.containsKey(element["employee_id"])) {
              //getting the user data from his id
              EmployeeInfo employee =
                  await _fetchEmployeeInfo(int.parse(element["employee_id"]));
              employees.putIfAbsent(element["employee_id"], () => employee);
            }
            //getting the client visit info from the fetched data
            ReportInfo report = ReportInfo.fromJSON(element);
            //adding the event info with the user data
            _reports.add(
              {
                //getting the employee data from the employee map by its id
                "employee": employees[element["employee_id"]],
                "report": report,
              },
            );
            update();
          },
        );
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "_fetchNewReports",
        data: "$error",
      );
      throw error;
    }
  }
}
