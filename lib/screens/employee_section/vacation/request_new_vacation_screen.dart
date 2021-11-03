import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../api/employee_data_api.dart';
import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/size.dart';
import '../../../models/vacation_info.dart';
import '../../../widgets/widgets.dart';

class RequestNewVacationScreen extends StatefulWidget {
  static const String route_name = "request_new_vacation_screen";

  @override
  _RequestNewVacationScreenState createState() =>
      _RequestNewVacationScreenState();
}

class _RequestNewVacationScreenState extends State<RequestNewVacationScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();
  final EmployeeDataUploaderAPI _uploader = EmployeeDataUploaderAPI();

  List<Map<String, Object>> reasons = [];
  Map<String, Object>? _selectedReason;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  TextEditingController _description = TextEditingController();
  TextEditingController _duration = TextEditingController();
  late VacationInfo vacation;

  bool _firstTime = true;
  bool _loadingReasons = true;

  @override
  void initState() {
    super.initState();
    _duration.addListener(() {
      setState(() {
        _toDate = _fromDate.add(Duration(
          days: ((int.tryParse(_duration.text) ?? 1) - 1),
        ));
      });
    });

    fetchReasons();
  }

  Future<void> fetchReasons() async {
    reasons = await _employeeDataAPI.fetchVacationReasons().catchError(
      (error) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      },
    );
    setState(() {
      _loadingReasons = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingReasons) {
      return Scaffold(
        body: PreLoader(),
      );
    } else {
      if (_firstTime) {
        vacation = ModalRoute.of(context)!.settings.arguments as VacationInfo;
        _duration.text =
            (vacation.endDate.day - vacation.startDate.day + 1).toString();
        _fromDate = vacation.startDate;
        _toDate = vacation.endDate;
        _description.text = vacation.description;
        _firstTime = false;
        _selectedReason = vacation.vacationTypeID.isEmpty
            ? null
            : reasons.firstWhere((element) =>
                element["id"].toString() == vacation.vacationTypeID);
      }
      Size _size = Size(context);
      return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Calender(
              fromYear: DateTime.now().year,
              titleKey: "request_new_vacation",
              color: (date) {
                DateTime fromTemp =
                    DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
                DateTime toTemp =
                    DateTime(_toDate.year, _toDate.month, _toDate.day);
                if ((date.toUtc().isAfter(fromTemp.toUtc()) &&
                        date.toUtc().isBefore(toTemp.toUtc())) ||
                    date.toUtc() == fromTemp.toUtc() ||
                    date.toUtc() == toTemp.toUtc()) return Colors.white;
                return Colors.transparent;
              },
              onChange: (date) {
                setState(() {
                  _fromDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _fromDate.hour,
                    _fromDate.minute,
                    _fromDate.second,
                  );
                  _toDate = _fromDate.add(
                    Duration(days: (int.tryParse(_duration.text) ?? 1) - 1),
                  );
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(43)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("vacation_reason"),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                  SizedBox(height: _size.height(17)),
                  _buildDropdownButton(_size),
                  SizedBox(height: _size.height(20)),
                  CustomTextField(
                    hintKey: "vacation_duration",
                    headerKey: "vacation_duration",
                    height: 70,
                    width: 343,
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    padding: EdgeInsets.symmetric(horizontal: _size.width(17)),
                  ),
                  SizedBox(height: _size.height(20)),
                  CustomTextField(
                    hintKey: "vacation_description",
                    headerKey: "vacation_description",
                    height: 217,
                    width: 343,
                    expands: true,
                    controller: _description,
                    keyboardType: TextInputType.multiline,
                    padding: EdgeInsets.all(_size.width(14)),
                  ),
                  SizedBox(height: _size.height(30)),
                  _buildSubmitButton(),
                  SizedBox(height: _size.height(54)),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  CustomElevatedButton _buildSubmitButton() {
    return CustomElevatedButton(
      onTap: () async {
        FocusScope.of(context).unfocus();
        if (_selectedReason == null || _description.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Get.find<AppLocalizationController>()
                  .getTranslatedValue("empty_fields_message")),
            ),
          );
        } else {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => PreLoader(),
          );
          bool uploaded = await _uploader
              .requestVacation(
            _selectedReason!["id"].toString(),
            _fromDate,
            _toDate,
            _description.text,
            vacation.id.toString(),
            vacation.canEdit,
          )
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              Navigator.pop(context);
            },
          );
          Navigator.of(context).pop();
          if (uploaded) {
            Navigator.of(context).pop(
              VacationInfo(
                id: vacation.id,
                description: _description.text,
                reason: _selectedReason!["name"] as String,
                vacationTypeID: _selectedReason!["id"].toString(),
                startDate: _fromDate,
                endDate: _toDate,
                state: vacation.state,
                canEdit: vacation.canEdit,
              ),
            );
          }
        }
      },
      width: 344,
      height: 72,
      child: Text(
        Get.find<AppLocalizationController>()
            .getTranslatedValue("request_a_vacation"),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildDropdownButton(Size _size) {
    return CustomDropdownButton<int>(
      width: double.infinity,
      maxHeight: _size.height(300),
      height: _size.height(72),
      padding: EdgeInsets.symmetric(
        horizontal: _size.width(20),
      ),
      buttonColor: Color.fromRGBO(236, 238, 244, 1),
      borderRadius: _size.width(14),
      listColor: Color.fromRGBO(255, 255, 255, 1),
      icon: SvgPicture.asset(
        "assets/icons/arrow_down.svg",
        color: Color.fromRGBO(196, 198, 204, 1),
      ),
      value: _selectedReason == null ? null : _selectedReason!["id"] as int?,
      hint: Row(
        children: [
          Container(
            width: _size.width(283),
            child: Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("vacation_reason"),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Color.fromRGBO(196, 198, 204, 1),
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
      items: reasons
          .map<CustomDropdownButtonItem<int>>(
            (reason) => _buildCustomDropdownButtonItem(reason, _size),
          )
          .toList(),
      onChange: (dynamic value) {
        setState(
          () {
            _selectedReason =
                reasons.firstWhere((element) => element["id"] == value);
          },
        );
      },
    );
  }

  CustomDropdownButtonItem<int> _buildCustomDropdownButtonItem(
      Map<String, Object> reason, Size _size) {
    return CustomDropdownButtonItem<int>(
      value: reason["id"] as int,
      child: Row(
        children: [
          Container(
            width: _size.width(283),
            child: Text(
              reason["name"].toString(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
