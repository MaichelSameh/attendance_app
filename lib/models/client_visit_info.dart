import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class ClientVisitInfo {
  late final String _id;
  late String _nextAction;
  late double _longitude;
  late double _latitude;
  late DateTime _startVisitTime;
  late DateTime? _startMeetingTime;
  late DateTime? _endMeetingTime;
  late String _capturedImageLink;
  String _address = "";
  String _name = "";

  String get id => _id;
  String get nextAction => _nextAction;
  double get longitude => _longitude;
  double get latitude => _latitude;
  DateTime get startVisitTime => _startVisitTime;
  DateTime? get startMeetingTime => _startMeetingTime;
  DateTime? get endMeetingTime => _endMeetingTime;
  String get capturedImageLink => _capturedImageLink;
  String get address => this._address;
  String get name => this._name;

  ClientVisitInfo.empty() {
    this._id = "";
    this._latitude = 0;
    this._longitude = 0;
    this._capturedImageLink = "";
    this._startVisitTime = DateTime.now();
    this._endMeetingTime = DateTime.now();
    this._startMeetingTime = DateTime.now();
    this._nextAction = "";
  }
  ClientVisitInfo.fromJSON(Map<String, dynamic>? jsonData) {
    if (jsonData == null) {
      jsonData = ClientVisitInfo.empty().toJson();
    }
    this._capturedImageLink = jsonData["captured_photo"] ?? "";
    this._id = jsonData["id"].toString();
    this._latitude = double.tryParse(jsonData["meet_lat"].toString()) ?? 0;
    this._longitude = double.tryParse(jsonData["meet_lon"].toString()) ?? 0;
    this._nextAction = jsonData["next_action"] ?? "";
    this._endMeetingTime = DateTime.tryParse(jsonData["end_time"] ?? "");
    this._startMeetingTime = DateTime.tryParse(jsonData["meet_time"] ?? "");
    this._name = jsonData["client_name"] ?? "";
    this._startVisitTime =
        DateTime.tryParse(jsonData["start_time"] ?? "") ?? DateTime.now();
    placemarkFromCoordinates(latitude, longitude).then((value) {
      this._address = value.first.country! +
          ", " +
          value.first.administrativeArea! +
          ", " +
          value.first.locality!.replaceAll(",", "");
    });
  }

  Map<String, dynamic> toJson() {
    return {
      "captured_photo": this.capturedImageLink,
      "end_time": DateFormat("yyyy-MM-dd", "en")
          .format(endMeetingTime ?? DateTime.now()),
      "id": this.id,
      "meet_lat": this.latitude,
      "meet_lon": this.longitude,
      "next_action": this.nextAction,
      "meet_time": DateFormat("yyyy-MM-dd", "en")
          .format(startMeetingTime ?? DateTime.now()),
      "start_time": DateFormat("yyyy-MM-dd", "en").format(startVisitTime),
    };
  }

  @override
  String toString() {
    return '''
      id: $id,
      next_action: $nextAction,
      longitude: $longitude,
      latitude: $latitude,
      start_visit_time: $startVisitTime,
      start_meeting_time: $startMeetingTime,
      end_meeting_timeL $endMeetingTime,
      captured_image: $capturedImageLink,
      address: $address,
      name: $name
    ''';
  }
}
