class UserInfo {
  late final String _name;
  late final String _role;
  late final String _profileImage;
  late final String _phoneNumber;
  late final String _email;
  late final String _departmentName;

  late final bool _isManager;
  late final bool _isSalesman;
  late final bool _canStartWork;
  late final bool _canEndWork;
  late final bool _canStartClientVisit;
  late final bool _canStartClientMeeting;
  late final bool _canEndClientVisit;
  late final bool _needCamera;

  UserInfo.fromJSON(Map<String, dynamic> jsonData, String? imagePath) {
    this._name = jsonData["name"].toString();
    this._role = jsonData["role"].toString();
    this._profileImage = imagePath ?? jsonData["profile"];
    this._phoneNumber = jsonData["phone"].toString();
    this._email = jsonData["email"].toString();
    this._departmentName = jsonData["department_name"].toString();
    this._canStartWork = jsonData["can_click_start_work"] ?? false;
    this._canEndWork = jsonData["can_click_end_work"] ?? false;
    this._canStartClientMeeting = jsonData["can_start_meeting"] ?? false;
    this._canStartClientVisit = jsonData["can_start_client_visit"] ?? false;
    this._canEndClientVisit = jsonData["can_end_client_visit"] ?? false;
    this._isManager = jsonData["type"] == "manager";
    this._isSalesman = jsonData["type"] == "salesman";
    this._needCamera = jsonData["should_captured_photo"];
  }

  UserInfo.empty() {
    this._name = "";
    this._role = "";
    this._isManager = false;
    this._profileImage = "";
    this._phoneNumber = "";
    this._email = "";
    this._departmentName = "";
    this._canEndWork = false;
    this._canStartClientMeeting = false;
    this._canStartClientVisit = false;
    this._canEndClientVisit = false;
    this._canStartWork = false;
    this._isSalesman = false;
    this._needCamera = true;
  }

  String get role => this._role;
  String get name => this._name;
  String get profileImage => _profileImage;
  String get phoneNumber => this._phoneNumber;
  String get email => this._email;
  String get department => this._departmentName;
  bool get isManager => this._isManager;
  bool get canStartWork => this._canStartWork;
  bool get canStartClientVisit => this._canStartClientVisit;
  bool get canStartClientMeeting => this._canStartClientMeeting;
  bool get canEndWork => this._canEndWork;
  bool get canEndClientVisit => this._canEndClientVisit;
  bool get needCamera => this._needCamera;
  bool get isSalesman => this._isSalesman;

  @override
  String toString() {
    return '''
    role: $role,
    name: $name,
    profile_image: $profileImage,
    phone_number: $phoneNumber,
    email: $email,
    department: $department,
    is_manager: $isManager,
    can_start_work: $canStartWork,
    can_start_client_visit: $canStartClientVisit,
    can_start_client_meeting: $canStartClientMeeting,
    can_end_work: $canEndWork,
    can_end_client_visit: $canEndClientVisit,
    need_camera: $needCamera,
    is_salesman: $isSalesman
    ''';
  }
}
