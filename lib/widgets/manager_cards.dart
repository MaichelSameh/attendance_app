import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../api/manager_data_api.dart';
import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import 'cards.dart';
import 'custom_profile_header.dart';
import 'pre_loader.dart';

class _ManagerBaseCard extends StatelessWidget {
  late final DateTime _date;
  late final List<Color> _gradient;
  late final Color _color;
  late final String _iconName;
  late final Widget _details;
  late final Widget _leading;
  late final double _iconWidth;
  late final double _iconHeight;
  late final EmployeeInfo _employee;

  late final PermissionState? _permissionStatus;

  _ManagerBaseCard({
    required DateTime date,
    required Widget details,
    required CardType cardType,
    required EmployeeInfo employee,
    List<Color> gradient = const [],
    Color color = const Color.fromRGBO(58, 120, 242, 1),
    Widget leading = const SizedBox(),
    PermissionState? permissionState,
  }) {
    this._date = date;
    this._gradient = gradient;
    this._color = color;
    this._details = details;
    this._leading = leading;
    this._employee = employee;
    this._permissionStatus = permissionState;
    switch (cardType) {
      case CardType.Attendance:
        this._iconWidth = 31.11;
        this._iconHeight = 31.11;
        this._iconName = "attendance_icon";
        break;
      case CardType.ClientVisit:
        this._iconWidth = 34.77;
        this._iconHeight = 25.29;
        this._iconName = "visit_icon";
        break;
      case CardType.Delay:
        this._iconWidth = 31.11;
        this._iconHeight = 31.11;
        this._iconName = "attendance_icon";
        break;
      case CardType.Permission:
        this._iconWidth = 36.13;
        this._iconHeight = 28.91;
        this._iconName = "permission_icon";
        break;
      case CardType.Report:
        this._iconWidth = 31.44;
        this._iconHeight = 36.99;
        this._iconName = "report_icon";
        break;
      case CardType.Vacation:
        this._iconWidth = 36.24;
        this._iconHeight = 28.99;
        this._iconName = "vacation_icon";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    return Center(
      child: Container(
        width: _size.width(368),
        margin: EdgeInsets.symmetric(vertical: _size.height(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            _size.width(41),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(226, 226, 226, 0.16),
              offset: Offset(0, 4),
              blurRadius: 17,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomProfileHeader(
              employee: _employee,
            ),
            if (_permissionStatus != null)
              Padding(
                padding: EdgeInsets.only(
                  top: _size.height(18),
                  left: _size.width(23),
                  right: _size.width(23),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PermissionStateCard(_permissionStatus!, false),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: _size.width(23),
                right: _size.width(23),
                top: _size.height(8),
                bottom: _size.height(11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: _size.width(67),
                    height: _size.height(128),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_size.width(24)),
                      color: _gradient.length >= 2 ? null : _color,
                      gradient: _gradient.length < 2
                          ? null
                          : LinearGradient(
                              colors: _gradient,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(11),
                      vertical: _size.height(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/$_iconName.svg",
                          height: _size.height(_iconHeight),
                          width: _size.width(_iconWidth),
                          matchTextDirection: true,
                        ),
                        SizedBox(height: _size.height(5)),
                        Text(
                          _date.day.toString(),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          DateFormat("MMM").format(_date).toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: _size.width(20)),
                  _details,
                  Spacer(),
                  _leading,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagerAttendanceCard extends StatelessWidget {
  late final DateTime _startDate;
  late final DateTime? _finishDate;

  late final bool _isAbsent;

  late final Color _color;

  late final bool _isDelay;
  late final bool _isVacation;

  late final EmployeeInfo _employee;

  ManagerAttendanceCard.present({
    required DateTime startDate,
    required DateTime? finishDate,
    required EmployeeInfo employee,
  }) {
    this._finishDate = finishDate;
    this._startDate = startDate;
    this._isAbsent = false;
    this._color = ConstData.green_color;
    this._isDelay = false;
    this._isVacation = false;
    this._employee = employee;
  }

  ManagerAttendanceCard.delay({
    required DateTime startDate,
    required DateTime? finishDate,
    required EmployeeInfo employee,
  }) {
    this._finishDate = finishDate;
    this._startDate = startDate;
    this._isAbsent = false;
    this._color = Color.fromRGBO(143, 30, 30, 1);
    this._isDelay = true;
    this._isVacation = false;
    this._employee = employee;
  }

  ManagerAttendanceCard.absent({
    required DateTime startDate,
    required EmployeeInfo employee,
  }) {
    this._startDate = startDate;
    this._finishDate = DateTime.now();
    this._isAbsent = true;
    this._color = Color.fromRGBO(237, 30, 84, 1);
    this._isDelay = false;
    this._isVacation = false;
    this._employee = employee;
  }

  ManagerAttendanceCard.vacation({
    required DateTime startDate,
    required EmployeeInfo employee,
  }) {
    this._startDate = startDate;
    this._finishDate = DateTime.now();
    this._isAbsent = true;
    this._color = Color.fromRGBO(4, 162, 174, 1);
    this._isDelay = false;
    this._employee = employee;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _ManagerBaseCard(
      employee: _employee,
      cardType: _isVacation
          ? CardType.Vacation
          : _isDelay
              ? CardType.Delay
              : CardType.Attendance,
      date: _startDate,
      color: _color,
      details: _isVacation
          ? _buildVacationDetails(context)
          : _isAbsent
              ? _buildAbsentDetails(context)
              : _buildPresentDetails(_size, context),
    );
  }

  Widget _buildAbsentDetails(BuildContext context) {
    return Center(
      child: Text(
        Get.find<AppLocalizationController>().getTranslatedValue("absent"),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildVacationDetails(BuildContext context) {
    return Center(
      child: Text(
        Get.find<AppLocalizationController>().getTranslatedValue("vacation"),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPresentDetails(Size _size, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue(_isDelay ? "delay" : "present")
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: _size.height(7)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat(Get.find<AppLocalizationController>().isRTLanguage
                            ? "mm : hh"
                            : "hh : mm")
                        .format(_startDate) +
                    " " +
                    (Get.find<AppLocalizationController>().getTranslatedValue(
                        _startDate.hour > 12 ? "pm" : "am")),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 13,
                    ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _size.width(6),
                ),
                child: SvgPicture.asset(
                  "assets/icons/to_icon.svg",
                  width: _size.width(15),
                  height: _size.height(8),
                  matchTextDirection: true,
                ),
              ),
              if (_finishDate != null)
                Text(
                  DateFormat(Get.find<AppLocalizationController>().isRTLanguage
                              ? "mm : hh"
                              : "hh : mm")
                          .format(_finishDate!) +
                      " " +
                      (Get.find<AppLocalizationController>().getTranslatedValue(
                          (_finishDate!).hour > 12 ? "pm" : "am")),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 13,
                      ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

class ManagerReportCard extends StatelessWidget {
  late final DateTime _date;
  late final String _title;
  late final EmployeeInfo _employee;

  ManagerReportCard({
    required DateTime date,
    required String title,
    required EmployeeInfo employee,
  }) {
    this._date = date;
    this._title = title;
    this._employee = employee;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _ManagerBaseCard(
      employee: _employee,
      cardType: CardType.Report,
      date: _date,
      details: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("report")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: _size.height(7)),
            Container(
              width: _size.width(160),
              child: Text(
                _title,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 13,
                    ),
                softWrap: true,
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ),
      color: Color.fromRGBO(11, 81, 145, 1),
    );
  }
}

class ManagerVacationCard extends StatelessWidget {
  late final DateTime _date;
  late final PermissionState _state;
  late final EmployeeInfo _employee;
  late final int _id;
  late final RefreshController? _refreshController;

  ManagerVacationCard({
    required int id,
    required DateTime date,
    required PermissionState state,
    required EmployeeInfo employee,
    RefreshController? refreshController,
  }) {
    this._date = date;
    this._state = state;
    this._employee = employee;
    this._id = id;
    this._refreshController = refreshController;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _ManagerBaseCard(
      employee: _employee,
      cardType: CardType.Vacation,
      date: _date,
      details: Center(
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("vacation")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      color: Color.fromRGBO(4, 162, 174, 1),
      permissionState: _state,
      leading: _state == PermissionState.Pending
          ? Container(
              height: _size.height(105),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (_) => PreLoader(),
                          barrierDismissible: false);
                      ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                      await _managerDataAPI
                          .updateVacation(_id, RequestStatus.Accepted)
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
                      if (_refreshController != null)
                        _refreshController!.requestRefresh();
                    },
                    child: CircleAvatar(
                      radius: _size.width(21),
                      backgroundColor: ConstData.green_color,
                      child: SvgPicture.asset(
                        "assets/icons/true_sign.svg",
                        color: Colors.white,
                        height: _size.height(15),
                        width: _size.width(10),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (_) => PreLoader(),
                          barrierDismissible: false);
                      ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                      await _managerDataAPI
                          .updateVacation(_id, RequestStatus.Rejected)
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
                      if (_refreshController != null)
                        _refreshController!.requestRefresh();
                    },
                    child: Container(
                      height: _size.width(42),
                      width: _size.width(42),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ConstData.failure_color,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/thin_cross_sign.svg",
                          color: ConstData.failure_color,
                          height: _size.height(20),
                          width: _size.width(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}

class ManagerClientVisitCard extends StatelessWidget {
  late final DateTime _date;
  late final EmployeeInfo _employee;
  late final String _clientName;

  ManagerClientVisitCard({
    required DateTime date,
    required EmployeeInfo employee,
    required String clientName,
  }) {
    this._date = date;
    this._employee = employee;
    this._clientName = clientName;
  }

  @override
  Widget build(BuildContext context) {
    return _ManagerBaseCard(
      employee: _employee,
      cardType: CardType.ClientVisit,
      date: _date,
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue("client_visit")
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            _clientName,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 14,
                  color: Color.fromRGBO(141, 141, 141, 1),
                ),
          ),
        ],
      ),
      color: Color.fromRGBO(249, 143, 103, 1),
    );
  }
}

class ManagerPermissionCard extends StatelessWidget {
  late final DateTime _date;
  late final PermissionState _state;
  late final String _permissionType;
  late final EmployeeInfo _employee;
  late final int _id;
  late final RefreshController? _refreshController;

  ManagerPermissionCard(
      {required DateTime date,
      required PermissionState state,
      required String permissionType,
      required EmployeeInfo employee,
      required int id,
      RefreshController? refreshController}) {
    this._date = date;
    this._permissionType = permissionType;
    this._state = state;
    this._employee = employee;
    this._id = id;
    this._refreshController = refreshController;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _ManagerBaseCard(
      employee: _employee,
      cardType: CardType.Permission,
      date: _date,
      details: Container(
        width: _size.width(160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("permission")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              _permissionType,
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
      permissionState: _state,
      color: Color.fromRGBO(38, 70, 83, 1),
      leading: _state == PermissionState.Pending
          ? Container(
              height: _size.height(105),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => PreLoader(),
                        barrierDismissible: false,
                      );
                      ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                      _managerDataAPI
                          .updatePermission(_id, RequestStatus.Accepted)
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
                      if (_refreshController != null)
                        _refreshController!.requestRefresh();
                    },
                    child: CircleAvatar(
                      radius: _size.width(21),
                      backgroundColor: ConstData.green_color,
                      child: SvgPicture.asset(
                        "assets/icons/true_sign.svg",
                        color: Colors.white,
                        height: _size.height(15),
                        width: _size.width(10),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => PreLoader(),
                        barrierDismissible: false,
                      );
                      ManagerDataAPI _managerDataAPI = ManagerDataAPI();
                      _managerDataAPI
                          .updatePermission(_id, RequestStatus.Rejected)
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
                      if (_refreshController != null)
                        _refreshController!.requestRefresh();
                    },
                    child: Container(
                      height: _size.width(42),
                      width: _size.width(42),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ConstData.failure_color,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/thin_cross_sign.svg",
                          color: ConstData.failure_color,
                          height: _size.height(20),
                          width: _size.width(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
