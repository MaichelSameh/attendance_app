import 'package:intl/intl.dart';

class ReportInfo {
  late final String _id;
  late String _title;
  late String _description;
  late String? _file;
  late DateTime _date;
  late bool _canEdit;

  String get id => _id;
  String get title => _title;
  String get description => _description;
  String? get fileName => file != null ? "file." + file!.split(".").last : null;
  String? get file => _file;
  DateTime get date => _date;
  bool get canEdit => _canEdit;

  void setFilePath(String file) {
    _file = file;
  }

  ReportInfo({
    required String id,
    required String description,
    required String title,
    required String? file,
    required DateTime date,
    required bool canEdit,
  }) {
    this._date = date;
    this._description = description;
    this._file = file;
    this._id = id;
    this._title = title;
    this._canEdit = canEdit;
  }
  ReportInfo.empty() {
    this._date = DateTime.now();
    this._description = "";
    this._file = "";
    this._id = "";
    this._title = "";
    this._canEdit = false;
  }

  ReportInfo.fromJSON(Map<String, dynamic>? jsonData) {
    if (jsonData == null) {
      jsonData = ReportInfo.empty().toJson();
    }
    this._date =
        DateTime.tryParse(jsonData["created_at"] ?? "") ?? DateTime.now();
    this._description = jsonData["description"] ?? "";
    this._file = jsonData["attached_file"];
    this._id = jsonData["id"].toString();
    this._title = jsonData["title"] ?? "";
    this._canEdit = jsonData["can_edit_or_delete"] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      "created_at": DateFormat("yyyy-MM-dd", "en").format(date),
      "description": this.description,
      "attached_file": this.file,
      "id": this.id,
      "title": this.title,
      "can_edit_or_delete": this.canEdit,
    };
  }

  @override
  String toString() {
    return '''
      id: $id,
      date: $date,
      description: $description,
      file_link: $file,
      title: $title,
      can_edit: $canEdit
    ''';
  }
}
