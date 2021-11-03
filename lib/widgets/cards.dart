import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/permission_info.dart';
import '../models/size.dart';

enum CardType { Vacation, Attendance, Delay, Report, Permission, ClientVisit }

class _BaseCard extends StatelessWidget {
  late final DateTime _date;
  late final List<Color> _gradient;
  late final Color _color;
  late final String _iconName;
  late final Widget _details;
  late final Widget _leading;
  late final double _iconWidth;
  late final double _iconHeight;
  _BaseCard({
    required DateTime date,
    required Widget details,
    required CardType cardType,
    List<Color> gradient = const [],
    Color color = const Color.fromRGBO(58, 120, 242, 1),
    Widget leading = const SizedBox(),
  }) {
    this._date = date;
    this._gradient = gradient;
    this._color = color;
    this._details = details;
    this._leading = leading;
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
        height: _size.height(140),
        padding: EdgeInsets.symmetric(horizontal: _size.width(23)),
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
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    DateFormat("MMM").format(_date).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
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
    );
  }
}

class PermissionStateCard extends StatelessWidget {
  late final PermissionState _state;
  late final Color _color;
  late final String _stateKey;
  late final bool _hasBottomPadding;
  PermissionStateCard(this._state, [this._hasBottomPadding = true]) {
    switch (_state) {
      case PermissionState.Accepted:
        _color = ConstData.green_color;
        _stateKey = "accepted";
        break;
      case PermissionState.Rejected:
        _color = Color.fromRGBO(246, 63, 63, 1);
        _stateKey = "rejected";
        break;
      case PermissionState.Pending:
        _color = Color.fromRGBO(255, 208, 54, 1);
        _stateKey = "pending";
        break;
      default:
        _color = Color.fromRGBO(255, 208, 54, 1);
        _stateKey = "pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: _size.height(_hasBottomPadding ? 70 : 0),
      ),
      child: Center(
        child: Container(
          width: _size.width(67),
          height: _size.height(35),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_size.width(4)),
            color: _color,
          ),
          child: Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue(_stateKey)
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  late final DateTime _startDate;
  late final DateTime? _finishDate;

  late final bool _isAbsent;

  late final Color _color;

  late final bool _isDelay;
  late final bool _isVacation;

  AttendanceCard.present({
    required DateTime startDate,
    required DateTime? finishDate,
  }) {
    this._finishDate = finishDate;
    this._startDate = startDate;
    this._isAbsent = false;
    this._color = ConstData.green_color;
    this._isDelay = false;
    this._isVacation = false;
  }

  AttendanceCard.delay({
    required DateTime startDate,
    required DateTime? finishDate,
  }) {
    this._finishDate = finishDate;
    this._startDate = startDate;
    this._isAbsent = false;
    this._color = Color.fromRGBO(143, 30, 30, 1);
    this._isDelay = true;
    this._isVacation = false;
  }

  AttendanceCard.absent({
    required DateTime startDate,
  }) {
    this._startDate = startDate;
    this._finishDate = DateTime.now();
    this._isAbsent = true;
    this._color = Color.fromRGBO(237, 30, 84, 1);
    this._isDelay = false;
    this._isVacation = false;
  }

  AttendanceCard.vacation({
    required DateTime startDate,
  }) {
    this._startDate = startDate;
    this._finishDate = DateTime.now();
    this._isAbsent = true;
    this._color = Color.fromRGBO(4, 162, 174, 1);
    this._isDelay = false;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _BaseCard(
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

class ReportCard extends StatelessWidget {
  late final DateTime _date;
  late final String _title;
  ReportCard({required DateTime date, required String title}) {
    this._date = date;
    this._title = title;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _BaseCard(
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

class VacationCard extends StatelessWidget {
  late final DateTime _date;
  late final PermissionState _state;
  VacationCard({
    required DateTime date,
    required PermissionState state,
  }) {
    this._date = date;
    this._state = state;
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
      leading: PermissionStateCard(_state),
    );
  }
}

class ClientVisitCard extends StatelessWidget {
  late final DateTime _date;
  late final String _clientName;
  ClientVisitCard({
    required DateTime date,
    required String clientName,
  }) {
    this._date = date;
    this._clientName = clientName;
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
                  fontSize: 16,
                  color: Color.fromRGBO(141, 141, 141, 1),
                ),
          ),
        ],
      ),
      color: Color.fromRGBO(249, 143, 103, 1),
    );
  }
}

class PermissionCard extends StatelessWidget {
  late final DateTime _date;
  late final PermissionState _state;
  late final String _permissionType;
  PermissionCard({
    required DateTime date,
    required PermissionState state,
    required String permissionType,
  }) {
    this._date = date;
    this._permissionType = permissionType;
    this._state = state;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return _BaseCard(
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
      leading: PermissionStateCard(_state),
      color: Color.fromRGBO(38, 70, 83, 1),
    );
  }
}
