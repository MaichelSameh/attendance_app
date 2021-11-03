class EmployeeInfo {
  late final String _name;
  late final String _role;
  late final int _id;
  late final String _profilePictureLink;

  EmployeeInfo.empty() {
    this._name = "Maichel Sameh";
    this._id = 0;
    this._profilePictureLink =
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJfa758-9Zet25uR43OnWUDxPh_5ivrKWg4g&usqp=CAU";
    this._role = "Developer";
  }

  EmployeeInfo.fromJSON(Map<String, dynamic> data) {
    this._id = data["id"];
    this._name = data["name"];
    this._profilePictureLink = data["profile_picture"];
    this._role = data["role"];
  }

  int get id => this._id;
  String get name => this._name;
  String get profilePictureLink => this._profilePictureLink;
  String get role => this._role;

  @override
  String toString() {
    return '''
    id: $id,
    name: $name,
    profile_image: $profilePictureLink,
    role: $role
  ''';
  }
}
