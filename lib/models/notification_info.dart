import 'package:get/get.dart';

import '../controllers/localization_controller.dart';

enum NotificationRequestTypes { Vacation, Permission, none }

class NotificationInfo {
  late final int _requestID;
  late final String _name;
  late final String _picture;
  late final NotificationRequestTypes _notificationType;
  late final String _description;
  NotificationInfo.employeeFromJSON(Map<String, dynamic> jsonData) {
    this._picture = jsonData["manager_profile_picture"] ?? "";
    this._name = jsonData["manager_name"] ?? "";
    this._requestID =
        jsonData[(jsonData["request_type"] ?? "") + "_request_id"] ?? 0;
    this._notificationType = jsonData["request_type"] == "vacation"
        ? NotificationRequestTypes.Vacation
        : jsonData["request_type"] == "permission"
            ? NotificationRequestTypes.Permission
            : NotificationRequestTypes.none;
    this._description = Get.find<AppLocalizationController>()
            .getTranslatedValue(
                jsonData["permission_status"] ?? "request_status") +
        " " +
        Get.find<AppLocalizationController>().getTranslatedValue("your") +
        " " +
        Get.find<AppLocalizationController>()
            .getTranslatedValue(jsonData["request_type"]) +
        "." +
        Get.find<AppLocalizationController>()
            .getTranslatedValue("tap_for_more");
  }

  NotificationInfo.managerFromJSON(Map<String, dynamic> jsonData) {
    this._picture = jsonData["employee_profile_picture"] ?? "";
    this._name = jsonData["employee_name"] ?? "";
    this._requestID = jsonData[jsonData["request_type"] + "_request_id"] ?? 0;
    this._notificationType = jsonData["request_type"] == "vacation"
        ? NotificationRequestTypes.Vacation
        : jsonData["request_type"] == "permission"
            ? NotificationRequestTypes.Permission
            : NotificationRequestTypes.none;
    this._description = Get.find<AppLocalizationController>()
            .getTranslatedValue("manager_notification_description") +
        " " +
        Get.find<AppLocalizationController>()
            .getTranslatedValue(jsonData["request_type"]) +
        "." +
        Get.find<AppLocalizationController>()
            .getTranslatedValue("tap_for_more");
  }

  NotificationInfo.empty() {
    this._requestID = 0;
    this._picture =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJfa758-9Zet25uR43OnWUDxPh_5ivrKWg4g&usqp=CAU";
    this._name = "Ahmed Ali";
    this._notificationType = NotificationRequestTypes.Permission;
  }

  String get imageURL => this._picture;
  String get name => this._name;
  String get description => this._description;
  int get requestID => this._requestID;
  NotificationRequestTypes get requestType => this._notificationType;

  @override
  String toString() {
    return '''\n
      description: $description,
      image_url: $imageURL,
      name: $name,
      request_id: $requestID,
      request_type: $requestType,
    ''';
  }
}
