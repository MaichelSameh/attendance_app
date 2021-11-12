import 'package:intl/intl.dart';

enum PermissionState { Accepted, Rejected, Pending }

class PermissionInfo {
  late final int _id;
  late String _permissionType;
  late final String _permissionTypeid;
  late String _description;
  late DateTime _dateTime;
  late PermissionState _state;
  late bool _canEdit;

  bool get canEdit => _canEdit;

  int get id => this._id;
  String get permissionType => this._permissionType;
  String get permissionTypeid => this._permissionTypeid;
  String get description => this._description;
  DateTime get dateTime => this._dateTime;
  PermissionState get state => this._state;

  PermissionInfo({
    required int id,
    required String description,
    required String permissionType,
    required String permissionTypeID,
    required DateTime date,
    required bool canEdit,
    required PermissionState state,
  }) {
    this._id = id;
    this._canEdit = canEdit;
    this._dateTime = date;
    this._description = description;
    this._permissionType = permissionType;
    this._permissionTypeid = permissionTypeID;
    this._state = state;
  }

  PermissionInfo.empty() {
    this._id = 0;
    this._canEdit = false;
    this._dateTime = DateTime.now();
    this._description = "";
    this._permissionType = "";
    this._permissionTypeid = "";
    this._state = PermissionState.Pending;
  }

  PermissionInfo.fromJSON(Map<String, dynamic>? jsonData) {
    if (jsonData == null) {
      jsonData = PermissionInfo.empty().toJson();
    }
    switch (jsonData["status"]) {
      case "accepted":
        this._state = PermissionState.Accepted;
        break;
      case "refused":
        this._state = PermissionState.Rejected;
        break;
      case "pending":
        this._state = PermissionState.Pending;
        break;
      default:
        this._state = PermissionState.Pending;
    }
    this._id = jsonData["id"];

    jsonData["time"] != null
        ? this._dateTime = DateTime.tryParse(jsonData["time"].toString()) ??
            DateTime.parse(
                (jsonData["from"] ?? "") + " " + (jsonData["time"] ?? ""))
        : _dateTime = DateTime.now();
    this._description = jsonData["description"] ?? "";
    this._permissionType = jsonData["permission_type"]["name"] ?? "";
    this._canEdit = jsonData["can_edit_or_delete"] ?? false;
    this._permissionTypeid = jsonData["permission_type"]["id"].toString();
  }

  Map<String, dynamic> toJson() {
    String state = "";

    switch (this.state) {
      case PermissionState.Accepted:
        state = "accepted";
        break;
      case PermissionState.Rejected:
        state = "rejected";
        break;
      case PermissionState.Pending:
        state = "pending";
        break;
    }
    return {
      "status": state,
      "description": this.description,
      "id": this.id,
      "permission_type": {"name": permissionType, "id": permissionTypeid},
      "from": DateFormat("yyyy-MM-dd", "en").format(dateTime),
      "can_edit_or_delete": this.canEdit,
    };
  }

  @override
  String toString() {
    String state = "";

    switch (this.state) {
      case PermissionState.Accepted:
        state = "accepted";
        break;
      case PermissionState.Rejected:
        state = "rejected";
        break;
      case PermissionState.Pending:
        state = "pending";
        break;
    }
    return '''
      id: $id,
      can_edit: $canEdit,
      date: $dateTime,
      description: $description,
      permission_type: $permissionType,
      permission_type_id: $permissionTypeid,
      state: $state
    ''';
  }
}
