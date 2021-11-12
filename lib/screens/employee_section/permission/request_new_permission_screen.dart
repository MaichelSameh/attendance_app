import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/employee_data_api.dart';
import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/models.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class RequestNewPermissionScreen extends StatefulWidget {
  static const String route_name = "request_new_permission_screen";

  @override
  _RequestNewPermissionScreenState createState() =>
      _RequestNewPermissionScreenState();
}

class _RequestNewPermissionScreenState
    extends State<RequestNewPermissionScreen> {
  final EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();
  final EmployeeDataUploaderAPI _uploader = EmployeeDataUploaderAPI();

  List<Map<String, Object>> reasons = [];

  Map<String, Object>? _selectedReason;
  String? _period;

  TextEditingController _description = TextEditingController();

  bool firstTime = true;
  bool _loadingReasons = true;

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().add(Duration(hours: 1)).hour,
    0,
  );

  PermissionInfo permission = PermissionInfo.empty();
  @override
  void initState() {
    super.initState();
    fetchReasons();
  }

  Future<void> fetchReasons() async {
    reasons = await _employeeDataAPI.fetchPermissionReasons().catchError(
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

  List<Map<String, Object>> getInRange(int range) {
    List<Map<String, Object>> list = [];
    for (int i = 0; i < range; i++) {
      list.add({
        "id": int.parse(DateFormat("yy", "en").format(DateTime(
          i,
        ))),
        "name": DateFormat("yy").format(DateTime(
          i,
        )),
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingReasons) {
      return Scaffold(
        body: PreLoader(),
      );
    }
    if (firstTime) {
      permission = ModalRoute.of(context)!.settings.arguments as PermissionInfo;
      _description.text = permission.description;
      _selectedDate = permission.dateTime;
      firstTime = false;
      _selectedReason = permission.permissionTypeid.isEmpty
          ? null
          : reasons.firstWhere((element) =>
              element["id"].toString() == permission.permissionTypeid);
    }
    Size _size = Size(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Calender(
            titleKey: "request_new_permission",
            fromYear: DateTime.now().year,
            color: (date) {
              DateTime temp = DateTime(
                  _selectedDate.year, _selectedDate.month, _selectedDate.day);
              if (date.toUtc() == temp.toUtc()) return Colors.white;
              return Colors.transparent;
            },
            onChange: (date) => setState(() {
              _selectedDate = DateTime(
                date.year,
                date.month,
                date.day,
                _selectedDate.hour,
                _selectedDate.minute,
                _selectedDate.second,
              );
            }),
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
                          .getTranslatedValue("permission_reason"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                SizedBox(height: _size.height(17)),
                _buildDropdownButton(
                    size: _size,
                    items: reasons,
                    onChange: (dynamic value) {
                      setState(
                        () {
                          _selectedReason = reasons
                              .firstWhere((element) => element["id"] == value);
                        },
                      );
                    },
                    value: _selectedReason == null
                        ? null
                        : _selectedReason!["id"] as int?,
                    expanded: true,
                    hintText: Get.find<AppLocalizationController>()
                        .getTranslatedValue("permission_reason")),
                SizedBox(height: _size.height(20)),
                if (_selectedReason == null
                    ? false
                    : _selectedReason!["need_time"] == 1)
                  _buildTimeSelector(_size),
                SizedBox(height: _size.height(20)),
                CustomTextField(
                  hintKey: "permission_description",
                  headerKey: "permission_description",
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

  CustomElevatedButton _buildSubmitButton() {
    return CustomElevatedButton(
      width: 344,
      height: 72,
      child: Text(
        Get.find<AppLocalizationController>()
            .getTranslatedValue("request_a_permission"),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
      ),
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
              .requestPermission(
            _selectedReason!["id"].toString(),
            _selectedDate,
            _description.text,
            permission.id.toString(),
            permission.canEdit,
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
          Navigator.pop(context);
          if (uploaded) {
            Navigator.of(context).pop(
              PermissionInfo(
                id: permission.id,
                description: _description.text,
                permissionType: _selectedReason!["name"] as String,
                permissionTypeID: _selectedReason!["id"].toString(),
                date: _selectedDate,
                canEdit: permission.canEdit,
                state: permission.state,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildTimeSelector(Size _size) {
    double width = _size.width(341) / 3 - _size.width(10);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              Get.find<AppLocalizationController>().getTranslatedValue("time"),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
        SizedBox(height: _size.height(17)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDropdownButton(
              width: width,
              size: _size,
              items: getInRange(13)..removeAt(0),
              onChange: (dynamic value) {
                setState(
                  () {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      (_period ==
                                  Get.find<AppLocalizationController>()
                                      .getTranslatedValue("pm")
                              ? 12
                              : 0) +
                          (value as int? ?? 0),
                      _selectedDate.minute,
                    );
                  },
                );
              },
              value: getInRange(13).firstWhere((element) =>
                  element["name"] ==
                  DateFormat("hh").format(_selectedDate))["id"] as int,
              hintText: DateFormat('hh').format(_selectedDate),
            ),
            _buildDropdownButton(
                width: width,
                size: _size,
                items: getInRange(60),
                onChange: (dynamic value) {
                  setState(
                    () {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedDate.hour,
                        value ?? 0,
                      );
                    },
                  );
                },
                hintText: DateFormat('mm').format(_selectedDate),
                value: getInRange(60).firstWhere((element) =>
                    element["name"] ==
                    DateFormat("mm").format(_selectedDate))["id"] as int),
            _buildDropdownButton(
              width: width,
              size: _size,
              items: [
                {
                  "id": 0,
                  "name": Get.find<AppLocalizationController>()
                      .getTranslatedValue("am")
                },
                {
                  "id": 1,
                  "name": Get.find<AppLocalizationController>()
                      .getTranslatedValue("pm")
                },
              ],
              onChange: (dynamic value) {
                setState(
                  () {
                    _period = value == 0
                        ? Get.find<AppLocalizationController>()
                            .getTranslatedValue("am")
                        : Get.find<AppLocalizationController>()
                            .getTranslatedValue("pm");
                  },
                );
              },
              value: _period ==
                      Get.find<AppLocalizationController>()
                          .getTranslatedValue("am")
                  ? 0
                  : 1,
              hintText: _period ?? "",
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownButton(
      {required Size size,
      required List<Map<String, Object>> items,
      required void Function(int?) onChange,
      required int? value,
      required String hintText,
      bool expanded = false,
      double width = double.infinity,
      EdgeInsets? padding}) {
    return Container(
      child: CustomDropdownButton<int>(
        align: CustomDropdownButtonAlign.BOTTOM,
        padding: padding == null
            ? EdgeInsets.symmetric(
                horizontal: size.width(20),
              )
            : padding,
        maxHeight: size.height(300),
        height: size.height(72),
        width: width,
        buttonColor: Color.fromRGBO(236, 238, 244, 1),
        borderRadius: size.width(14),
        listShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Color.fromRGBO(176, 177, 181, 1),
          ),
        ],
        icon: SvgPicture.asset(
          "assets/icons/arrow_down.svg",
          color: Color.fromRGBO(196, 198, 204, 1),
        ),
        value: value,
        hint: Container(
          child: Text(
            hintText,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Color.fromRGBO(196, 198, 204, 1),
                  fontSize: 14,
                ),
          ),
          width: expanded ? size.width(283) : null,
          padding: EdgeInsets.only(right: size.width(20)),
        ),
        items: items
            .map<CustomDropdownButtonItem<int>>(
              (item) => _dropdownMenuItem(item, size),
            )
            .toList(),
        onChange: onChange,
      ),
    );
  }

  CustomDropdownButtonItem<int> _dropdownMenuItem(
      Map<String, Object> item, Size _size) {
    return CustomDropdownButtonItem<int>(
      value: item["id"] as int,
      child: Text(
        Get.find<AppLocalizationController>()
            .getTranslatedValue(item["name"] as String),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.black,
              fontSize: 14,
            ),
      ),
    );
  }
}
