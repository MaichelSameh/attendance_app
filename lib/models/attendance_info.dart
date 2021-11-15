import 'package:intl/intl.dart';

enum AttendanceState { Present, Absent, Delay, Vacation }

class AttendanceInfo {
  late final String _id;
  late DateTime _startDate;
  late DateTime? _endDate;
  late final DateTime _date;
  late AttendanceState _state;
  late final int _delay;

  String get id => this._id;
  DateTime get startDate => this._startDate;
  DateTime? get endDate => this._endDate;
  DateTime get date => this._date;
  AttendanceState get state => this._state;
  int get delay => this._delay;

  AttendanceInfo.fromJSON(Map<String, dynamic>? jsonData) {
    if (jsonData == null) {
      jsonData = AttendanceInfo.empty().toJson();
    }
    this._id = jsonData["id"].toString();
    this._startDate =
        DateTime.tryParse(jsonData["clock_in_time"] ?? "") ?? DateTime.now();
    this._endDate = DateTime.tryParse(jsonData["clock_out_time"] ?? "");
    this._date = DateTime.tryParse(jsonData["date"] ?? "") ?? this.startDate;
    this._delay = int.parse(jsonData["delay"].toString());
    switch (jsonData["type"]) {
      case "attend":
        this._state =
            this._delay == 0 ? AttendanceState.Present : AttendanceState.Delay;
        break;
      case "delay":
        this._state = AttendanceState.Delay;
        break;
      case "vacation":
        this._state = AttendanceState.Vacation;
        break;
      default:
        this._state = AttendanceState.Absent;
    }
  }

  AttendanceInfo.empty() {
    this._id = "temp";
    this._startDate = DateTime.now();
    this._endDate = DateTime.now();
    this._date = DateTime.now();
    this._delay = 0;
    this._state = AttendanceState.Absent;
  }

  Map<String, dynamic> toJson() {
    String state = "";
    switch (this.state) {
      case AttendanceState.Present:
        state = "attend";
        break;
      case AttendanceState.Absent:
        state = "absent";
        break;
      case AttendanceState.Delay:
        state = "delay";
        break;
      case AttendanceState.Vacation:
        state = "vacation";
    }

    return {
      "clock_in_time": DateFormat("yyyy-MM-dd", "en").format(_startDate),
      "clock_out_time":
          DateFormat("yyyy-MM-dd", "en").format(_endDate ?? _startDate),
      "type": state,
      "id": id,
      "delay": delay,
    };
  }

  @override
  String toString() {
    String state = "";
    switch (this.state) {
      case AttendanceState.Present:
        state = "attend";
        break;
      case AttendanceState.Absent:
        state = "absent";
        break;
      case AttendanceState.Delay:
        state = "delay";
        break;
      case AttendanceState.Vacation:
        state = "vacation";
    }
    return '''
      id: $id,
      start_time: $startDate,
      end_time: $endDate,
      date: $date,
      state: $state,
      delay: $delay
    ''';
  }
}
