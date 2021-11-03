import 'package:intl/intl.dart';

import 'permission_info.dart';

class VacationInfo {
  late final PermissionState _state;
  late final DateTime _startDate;
  late final DateTime _endDate;
  late final int _id;
  late final String _reason;
  late final String _description;
  late final bool _canEdit;
  late final String _vacationTypeId;

  PermissionState get state => this._state;
  DateTime get startDate => this._startDate;
  int get id => this._id;
  DateTime get endDate => this._endDate;
  String get description => this._description;
  String get reason => this._reason;
  String get vacationTypeID => this._vacationTypeId;
  bool get canEdit => this._canEdit;

  VacationInfo({
    required int id,
    required String description,
    required String reason,
    required String vacationTypeID,
    required DateTime startDate,
    required DateTime endDate,
    required PermissionState state,
    required bool canEdit,
  }) {
    this._state = state;
    this._canEdit = canEdit;
    this._description = description;
    this._id = id;
    this._reason = reason;
    this._startDate = startDate;
    this._endDate = endDate;
    this._vacationTypeId = vacationTypeID;
  }

  VacationInfo.empty() {
    this._state = PermissionState.Pending;
    this._canEdit = false;
    this._description = "";
    this._id = 0;
    this._reason = "";
    this._startDate = DateTime.now();
    this._endDate = DateTime.now();
    this._vacationTypeId = "";
  }

  VacationInfo.fromJSON(Map<String, dynamic>? jsonData) {
    if (jsonData == null) {
      jsonData = VacationInfo.empty().toJSON();
    }
    this._endDate = DateTime.parse(jsonData["to"]);
    this._id = jsonData["id"];
    this._startDate = DateTime.parse(jsonData["from"]);
    switch (jsonData["status"]) {
      case "accepted":
        this._state = PermissionState.Accepted;
        break;
      case "rejected":
        this._state = PermissionState.Rejected;
        break;
      case "pending":
        this._state = PermissionState.Pending;
        break;
      default:
        this._state = PermissionState.Pending;
    }
    this._description = jsonData["description"] ?? "";
    this._reason = jsonData["vacation_type"]["name"];
    this._canEdit = jsonData["can_edit_or_delete"] ?? false;
    this._vacationTypeId = jsonData["vacation_type"]["id"].toString();
  }

  Map<String, dynamic> toJSON() {
    String status;
    switch (state) {
      case PermissionState.Accepted:
        status = "accepted";
        break;
      case PermissionState.Pending:
        status = "pending";
        break;
      case PermissionState.Rejected:
        status = "rejected";
        break;
    }
    return {
      "id": id,
      "status": status,
      "description": description,
      "vacation_type": {"name": reason, "id": vacationTypeID},
      "can_edit_or_delete": canEdit,
      "from": DateFormat("yyyy-MM-dd", "en").format(startDate),
      "to": DateFormat("yyyy-MM-dd", "en").format(endDate),
    };
  }

  @override
  String toString() {
    String status;
    switch (state) {
      case PermissionState.Accepted:
        status = "accepted";
        break;
      case PermissionState.Pending:
        status = "pending";
        break;
      case PermissionState.Rejected:
        status = "rejected";
        break;
    }
    return '''
      id: $id,
      description: $description,
      can_edit: $canEdit,
      state: $status,
      reason: $reason,
      start_date: $startDate,
      end_date: $endDate,
      vacation_type_id: $vacationTypeID
    ''';
  }
}
