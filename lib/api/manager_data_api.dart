import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../const/links.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';

enum RequestStatus { Accepted, Rejected }

class ManagerDataAPI {
  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("MANAGER_DATA_API $functionName $variableName: $data");
  }

  //updating the vacation status using its id to detect it and the enum RequestStatus to consider the next status
  Future<void> updateVacation(int id, RequestStatus status) async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.manager_update_vacation_state);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.post(
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
        body: {
          "id": id.toString(),
          "status": status == RequestStatus.Accepted ? "accepted" : "refused",
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //converting the response body
        Map<String, dynamic> resData = json.decode(res.body);
        throw resData["message"];
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
        functionName: "updateVacation",
        data: "$error",
      );
      throw error;
    }
  }

  //updating the permission status using its id to detect it and the enum RequestStatus to consider the next status
  Future<void> updatePermission(int id, RequestStatus status) async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.manager_update_permission_state);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.post(
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
        body: {
          "id": id.toString(),
          "status": status == RequestStatus.Accepted ? "accepted" : "refused",
        },
      );
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //converting the response body
        Map<String, dynamic> resData = json.decode(res.body);
        throw resData["message"];
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
        functionName: "updatePermission",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the employee information by the id to use it with the other data
  Future<EmployeeInfo> fetchEmployeeInfo(String id) async {
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
        functionName: "fetchEmployeeInfo",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the client visits created by the employee in the same department as the manager
  Future<List<Map<String, dynamic>>> fetchClientVisits(
    DateTime date, [
    int page = 1,
  ]) async {
    //declaring the client visits URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_client_visit_getter +
          "/${DateFormat("yyyy-MM-dd", "en").format(date)}",
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the client visit get link
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the client visit info from the fetched data
          ClientVisitInfo clientVisit = ClientVisitInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "client_visit": clientVisit,
            },
          );
        }
        // returning the fetched data after the formatting process
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

  //in this function we are fetching the reports sent by the employees in the same department
  //as the manager
  Future<List<Map<String, dynamic>>> fetchReports(
    DateTime date, [
    int page = 1,
  ]) async {
    //declaring the reports URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_reports_getter +
          "/${DateFormat("yyyy-MM-dd", "en").format(date)}",
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the reports get link
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the report info from the fetched data
          ReportInfo report = ReportInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "report": report,
            },
          );
        }
        // returning the fetched data after the formatting process
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

  //fetching all the vacations requested by the employees in the same department
  //as the manager
  Future<List<Map<String, dynamic>>> fetchVacationRequests(
    DateTime date, [
    int page = 1,
  ]) async {
    //declaring the vacations URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_vacations_getter +
          "/${DateFormat("yyyy-MM-dd", "en").format(date)}",
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the vacation get link
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the vacation info from the fetched data
          VacationInfo vacation = VacationInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "vacation": vacation,
            },
          );
        }
        // returning the fetched data after the formatting process
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchVacationRequests",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching all the permissions requested by the employees in the same department
  //as the manager
  Future<List<Map<String, dynamic>>> fetchPermissionsRequests(
    DateTime date, [
    int page = 1,
  ]) async {
    //declaring the permissions URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_permission_getter +
          "/${DateFormat("yyyy-MM-dd", "en").format(date)}",
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the permission get link
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the permission info from the fetched data
          PermissionInfo permission = PermissionInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "permission": permission,
            },
          );
        }
        // returning the fetched data after the formatting process
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchPermissionsRequests",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching the attendance for all the employees in the same department as the manager
  Future<List<Map<String, dynamic>>> fetchAttendance(
    DateTime date, {
    int page = 1,
    String filter = "all",
  }) async {
    //declaring the attendances URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_attendance_getter,
      {
        "page": page.toString(),
      },
    );
    try {
      //executing the attendance get link
      http.Response res = await http.post(link, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      }, body: {
        "date": DateFormat("yyyy-MM-dd", "en").format(date),
        "filter": filter,
      });
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the attendance info from the fetched data
          AttendanceInfo attendance = AttendanceInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "attendance": attendance,
            },
          );
        }
        // returning the fetched data after the formatting process
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchAttendance",
        data: "$error",
      );
      throw error;
    }
  }

  //getting the profile data from the server
  Future<List<Map<String, String>>> fetchEmployeeProfileData(
    int id,
    DateTime from,
    DateTime to,
  ) async {
    try {
      //creating the request link with the filter parameter
      final Uri link = Uri.https(
        ServerConstants.server_base_link,
        ServerConstants.manager_employee_profile_data_getter + "/$id",
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
          {"delay": (resData["delay_duration_sum"]).abs().toString()},
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
        functionName: "fetchEmployeeProfileData",
        data: "$error",
      );
      throw error;
    }
  }

  //in this function we are fetching the employees that are working in the same
  //department for the manager
  Future<List<EmployeeInfo>> fetchDepartmentEmployees([int page = 1]) async {
    //declaring the employees URL
    Uri link = Uri.https(
      ServerConstants.server_base_link,
      ServerConstants.manager_get_users,
      {
        "page": page.toString(),
      },
    );
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully
      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"]["data"];
        //creating a variable to hold all the data until return it
        List<EmployeeInfo> result = [];
        //looping throw the data fetched from the server
        data.forEach((element) async {
          //getting the employee info from the fetched data
          EmployeeInfo employee = EmployeeInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(employee);
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "fetchDepartmentEmployees",
        data: "$error",
      );
      throw error;
    }
  }

  //searching about a user by his name
  Future<List<EmployeeInfo>> searchEmployees(String name) async {
    //declaring the employees URL
    Uri link = Uri.https(ServerConstants.server_base_link,
        ServerConstants.manager_search_employee + "/$name");
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
      //extracting the response body
      dynamic resData = json.decode(res.body);
      //in this case the request had been completed successfully

      if (res.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = resData["data"]["data"];
        //creating a variable to hold all the data until return it
        List<EmployeeInfo> result = [];
        //looping throw the data fetched from the server
        data.forEach((element) async {
          //getting the employee info from the fetched data
          EmployeeInfo employee = EmployeeInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(employee);
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
        //throwing the error
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "searchEmployees",
        data: "$error",
      );
      throw error;
    }
  }

  //fetching all the pending requests in my department
  Future<List<Map<String, dynamic>>> fetchPendingRequests(
      [int page = 1]) async {
    List<Map<String, dynamic>> pendingRequests = [];
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
      //in this case the permissions request had been completed successfully
      if (permissionResponse.statusCode == 200) {
        //extracting the required data
        List<dynamic> data = permissionData["data"];
        //creating a variable to hold all the data until return it
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the permission info from the fetched data
          PermissionInfo permission = PermissionInfo.fromJSON(element);
          //adding the event info with the user data
          pendingRequests.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "permission": permission,
            },
          );
        }
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
        //creating a variable to hold all the data until return it
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the vacation info from the fetched data
          VacationInfo vacation = VacationInfo.fromJSON(element);
          //adding the event info with the user data
          pendingRequests.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "vacation": vacation,
            },
          );
        }
        pendingRequests.shuffle();
        return pendingRequests;
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

  //fetching the notifications from the server
  Future<List<NotificationInfo>> fetchNotification([int pageNumber = 1]) async {
    try {
      Uri link = Uri.https(ServerConstants.server_base_link,
          ServerConstants.manager_notification_getter);
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
          //adding the notification to the list as a manager notification
          notifications.add(NotificationInfo.managerFromJSON(notification));
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

  //searching about a user by his name
  Future<List<Map<String, dynamic>>> searchClientVisits(
    String clientName,
  ) async {
    //declaring the employees URL
    Uri link = Uri.https(ServerConstants.server_base_link,
        ServerConstants.manager_client_visits_search + "/$clientName");
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
        print(resData);
        //extracting the required data
        List<dynamic> data = resData["data"];
        //creating a variable to hold all the data until return it
        List<Map<String, dynamic>> result = [];
        Map<String, EmployeeInfo> employees = {};
        //looping throw the data fetched from the server
        for (var element in data) {
          //checking if we had already fetched this user before
          //this condition is used to reduce the requests sent to get employee
          //data
          if (!employees.containsKey(element["employee_id"])) {
            //getting the user data from his id
            EmployeeInfo employee =
                await fetchEmployeeInfo(element["employee_id"]);
            employees.putIfAbsent(element["employee_id"], () => employee);
          }
          //getting the client visit info from the fetched data
          ClientVisitInfo clientVisit = ClientVisitInfo.fromJSON(element);
          //adding the event info with the user data
          result.add(
            {
              //getting the employee data from the employee map by its id
              "employee": employees[element["employee_id"]],
              "client_visit": clientVisit,
            },
          );
        }
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
