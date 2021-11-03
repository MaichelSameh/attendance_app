import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/links.dart';
import '../models/models.dart';
import 'localization_controller.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  //adding email field to hold the email in case we need to use it later for example when we try to send a reset code
  String _email = "";

  String _tokenid = "";

  String get email => this._email;

  String get tokenid => this._tokenid;

  //in this function we are printing the outputs of this class with its reference
  void echo({
    required String variableName,
    required String functionName,
    required String data,
  }) {
    print("LOGIN_CONTROLLER $functionName $variableName: $data");
  }

  //checking if the user had logged in before using this device by checking the shared preferences
  Future<bool> get hasDeviceID async {
    //creating an instance from the shared preferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    //checking if we have any device id saved in the shared preferences and if it valid or not
    //to decide even if we are going to show a pop up to the user or not
    return pref.containsKey("had_device_id") &&
        (pref.getBool("had_device_id") ?? false);
  }

  // getting the notification tokenID from the firebase
  Future<String> get _getNotificationTokenid async {
    String token = await FirebaseMessaging.instance.getToken() ?? "no token";
    print(token);
    return token;
  }

  //trying to login and register the user data
  Future<bool> login(String email, String password) async {
    try {
      //getting the device id to register the user in
      final String deviceID = await _getDeviceID(email);
      //Getting the device notification tokenID from firebase
      final String notificationID = await _getNotificationTokenid;
      //creating the url for the login method
      final Uri loginURI = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_login_request);
      //sending a post request to register the user in
      final http.Response res = await http.post(
        loginURI,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
        },
        body: {
          //sending the required information to log the user in
          "login_id": email,
          "password": password,
          "device_id": deviceID,
          //this string must contains the device token from the firebase to send the push notification
          "push_id": notificationID,
        },
      );
      //getting the response body data
      Map<String, dynamic> resData = json.decode(res.body);
      //checking if the request completed successfully
      if (res.statusCode == 200) {
        //getting the tokenid from the response
        this._tokenid = resData["data"]["token"];
        //creating an instance from the shared preferences
        SharedPreferences pref = await SharedPreferences.getInstance();
        if (pref.get("profile_image_link") !=
            resData["data"]["employee"]["profile"])
          // saving the user image as a file in the device
          await _saveImages(
              resData["data"]["employee"]["profile"], "profile_image");
        update();
        //saving the employee data with the api
        await _saveLoginData(deviceID, tokenid, email, password);
        //converting the response body from json to a map
        UserInfo currentUser = UserInfo.fromJSON(
            resData["data"]["employee"], pref.getString("profile_image"));
        Get.find<UserController>().setUser(currentUser);
        //notifying all the listeners that we finished the request
        // saving the company data into the shared preferences
        await updateCompanyData(resData["data"]["company"]["name"],
            resData["data"]["company"]["logo"]);
        return true;
      } else if (res.statusCode == 401) {
        //throwing the error message
        throw resData["message"];
      }
      return false;
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "login",
        data: "$error",
      );
      throw error;
    }
  }

  //getting the device id using the package platform_device_id to register the
  //device in the database during the authentication process
  Future<String> _getDeviceID(String email) async {
    String? id = await PlatformDeviceId.getDeviceId;
    switch (email) {
      case "ID123456_C1": //normal account
        return "123458";
      case "ID123457_C1": //salesman account
        return "c211d86bd9d488eb";
      case "ID123458_C1": //manager
        return "a8b49a8adad0d346";
      default:
        return id ?? "";
    }
  }

  //saving the required information to get re-authenticate the user or to send a new request
  Future<void> _saveLoginData(
    String deviceID,
    String tokenid,
    String email,
    String password,
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("had_device_id", deviceID.isNotEmpty);
    pref.setString("tokenid", tokenid);
    pref.setString("email", email);
    pref.setString("password", password);
  }

  //sending a validation code to the given email to reset the password
  Future<bool> sendCodeEmail(String email) async {
    this._email = email;
    update();
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_send_email_request);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.post(
        permissionTypesLink,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
        },
        body: {
          "email": email,
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
        functionName: "sendCodeEmail",
        data: "$error",
      );
      throw error;
    }
  }

  //validating if the getting code is valid or not
  Future<bool> validateCode(String code) async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_verify_code_request);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.post(
        permissionTypesLink,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
        },
        body: {
          "email": email,
          "verfication_code": code,
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
        functionName: "validateCode",
        data: "$error",
      );
      throw error;
    }
  }

  //resetting the password again
  Future<bool> resetPassword(String password) async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_reset_password_request);
      //sending a get request to get back data from the server without changing any thing
      final http.Response res = await http.post(
        permissionTypesLink,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
        },
        body: {
          "email": email,
          'password': password,
          "password_confirmation": password,
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
        functionName: "resetPassword",
        data: "$error",
      );
      throw error;
    }
  }

  //changing the password by using the old one
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      //creating the request link
      final Uri permissionTypesLink = Uri.https(
          ServerConstants.server_base_link,
          ServerConstants.employee_update_password_request);
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
          "email": email,
          "password": newPassword,
          "old_password": oldPassword,
          "password_confirmation": newPassword,
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
        functionName: "changePassword",
        data: "$error",
      );
      throw error;
    }
  }

  //forgetting the user data and logging the user out
  Future<bool> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    if (!Get.find<UserController>().activeEmployeeMode)
      Get.find<UserController>().reverseManagerMode();
    try {
      Uri logoutLink = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_logout_request);
      final http.Response res = await http.post(logoutLink, headers: {
        //the response data format
        "Accept": ServerConstants.response_format,
        //the response language
        "X-localization":
            Get.find<AppLocalizationController>().currentLocale.languageCode,
        //sending the authentication key to get the exact employee data
        "Authorization": "Bearer ${Get.find<LoginController>().tokenid}",
      });
      if (res.statusCode == 200) {
        update();
        this._email = "";
        this._tokenid = "";
        return true;
      } else if (res.statusCode == 401) {
        Get.find<LoginController>().flushTokenid();
        throw Get.find<AppLocalizationController>()
            .getTranslatedValue("try_again");
      } else {
        var resData = json.decode(res.body);
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "logout",
        data: "$error",
      );
      throw error;
    }
  }

  //trying to login by using only the saved data without any extra information
  Future<bool> tryAutoLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey("tokenid")) {
      _tokenid = pref.getString("tokenid")!;
      this._email = pref.getString("email")!;
      await flushUserData();
      update();
      return true;
    }
    return false;
  }

  // getting a new tokenid and new data from the server
  Future<void> flushTokenid() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await login(
        pref.getString("email") ?? "", pref.getString("password") ?? "");
  }

  //saving the company name and logo in the shared preferences
  Future<void> updateCompanyData(String name, String logo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getString("company_logo_link") != logo) {
      await _saveImages(logo, "company_logo");
    }
    if (pref.getString("company_name") != name) {
      pref.setString("company_name", name);
    }
  }

  Future<void> _getDefaultCompanyData() async {
    ByteData byteData = await rootBundle.load("assets/logos/company_logo.svg");

    Directory documentDirectory = await getApplicationDocumentsDirectory();
    //getting the images directory
    final String filePath = documentDirectory.path + "/images";
    //getting the file name
    final String fileName = "company_logo" + '.svg';
    //creating the images directory
    await Directory(filePath).create(recursive: true);
    //creating the image file
    File file = File(filePath + "/" + fileName);
    //writing the image
    file.writeAsBytes(byteData.buffer.asUint8List());
    //creating an instance from the shared preferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    //setting the image path to be used later
    pref.setString("company_logo", filePath + "/" + fileName);
    pref.setString("company_name", "Arab Badia");
  }

  //fetching the company data from the shared preferences
  Future<Map<String, String>> getCompanyData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? logo = pref.getString("company_logo");
    String? name = pref.getString("company_name");
    if (name == null || logo == null) {
      await _getDefaultCompanyData();
    }
    logo = pref.getString("company_logo")!;
    name = pref.getString("company_name")!;
    return {
      "name": name,
      "logo": logo,
    };
  }

  //saving the images from the internet into the shared preferences
  Future<bool> _saveImages(String imageURL, String imageField) async {
    try {
      //fetching the image from the internet
      http.Response res = await http.get(Uri.parse(imageURL));
      //getting the app directory to store the image in
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      //getting the images directory
      final String filePath = documentDirectory.path + "/images";
      //getting the file name
      final String fileName = imageField + '.' + imageURL.split(".").last;
      //creating the images directory
      await Directory(filePath).create(recursive: true);
      //creating the image file
      File file = File(filePath + "/" + fileName);
      //writing the image
      file.writeAsBytesSync(res.bodyBytes);
      //creating an instance from the shared preferences
      SharedPreferences pref = await SharedPreferences.getInstance();
      //setting the image path to be used later
      pref.setString(imageField, filePath + "/" + fileName);
      //saving the image link to compare it later to get if it changed or not
      pref.setString(imageField + "_link", imageURL);
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "_saveImages",
        data: "$error",
      );
    }
    return false;
  }

  Future<void> flushUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      Uri meLink = Uri.https(ServerConstants.server_base_link,
          ServerConstants.employee_flush_data_request);
      final http.Response res = await http.get(
        meLink,
        headers: {
          //the response data format
          "Accept": ServerConstants.response_format,
          //the response language
          "X-localization":
              Get.find<AppLocalizationController>().currentLocale.languageCode,
          //sending the authentication key to get the exact employee data
          "Authorization": "Bearer $tokenid",
        },
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> resData = json.decode(res.body);
        if (pref.get("profile_image_link") !=
            resData["data"]["employee"]["profile"])
          // saving the user image as a file in the device
          await _saveImages(
              resData["data"]["employee"]["profile"], "profile_image");
        Get.find<UserController>().setUser(
          UserInfo.fromJSON(
              resData["data"]["employee"], pref.getString("profile_image")),
        );
        await updateCompanyData(
          resData["data"]["company"]["name"],
          resData["data"]["company"]["logo"],
        );
        update();
      } else if (res.statusCode == 401) {
        await Get.find<LoginController>().flushTokenid();
        throw Get.find<AppLocalizationController>()
            .getTranslatedValue("try_again");
      } else {
        Map<String, dynamic> resData = json.decode(res.body);
        throw resData["message"];
      }
    } catch (error) {
      echo(
        variableName: "error",
        functionName: "_flushUserData",
        data: "$error",
      );
      throw error;
    }
  }
}
