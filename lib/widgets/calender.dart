import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../const/const_data.dart';
import '../controllers/localization_controller.dart';
import '../models/size.dart';
import '/widgets/widgets.dart';

class Calender extends StatefulWidget {
  late final String _pageTitleKey;

  late final int _fromYear;
  late final int _toYear;

  late final void Function(DateTime) _onChange;
  late final Color Function(DateTime) _color;

  Calender({
    required String titleKey,
    void Function(DateTime date)? onChange,
    Color Function(DateTime date)? color,
    int? fromYear,
    int? toYear,
  }) {
    this._pageTitleKey = titleKey;
    this._onChange = onChange ?? (_) {};
    this._color = color ?? (_) => Colors.transparent;
    fromYear = fromYear ?? (DateTime.now().year - 5);
    toYear = toYear ?? (DateTime.now().year + 5);
    if (fromYear > DateTime.now().year) {
      throw "You can't start a calender from this year";
    }
    if (toYear < DateTime.now().year) {
      throw "You must include current year also";
    }
    this._toYear = toYear;
    this._fromYear = fromYear;
  }

  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _currentTime = DateTime.now();

  Map<int, String> _generateYearList() {
    Map<int, String> map = {};

    for (int i = widget._fromYear; i < widget._toYear; i++) {
      map.putIfAbsent(i, () => DateFormat("yyyy").format(DateTime(i)));
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Stack(
      children: [
        BackgroundSheet(height: _size.height(600)),
        BackgroundCircle(height: 460, width: 430),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _size.height(32)),
            GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.only(
                    top: _size.width(50),
                    bottom: _size.width(10),
                    left: Get.find<AppLocalizationController>().isRTLanguage
                        ? _size.width(50)
                        : _size.width(40),
                    right: !Get.find<AppLocalizationController>().isRTLanguage
                        ? _size.width(50)
                        : _size.width(40),
                  ),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/icons/back_arrow.svg",
                    color: Colors.white,
                    width: _size.width(18),
                    height: _size.height(15),
                  ),
                )),
            SizedBox(height: _size.height(13)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _size.width(40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue(widget._pageTitleKey)
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  SizedBox(height: _size.height(11)),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropDownButton(
                            _size, ConstData.listOfMonths, _currentTime.month,
                            (dynamic value) {
                          setState(() {
                            _currentTime = DateTime(_currentTime.year,
                                value ?? _currentTime.month, _currentTime.day);
                          });
                          widget._onChange(_currentTime);
                        }),
                        SizedBox(width: _size.width(27)),
                        _buildDropDownButton(
                            _size, _generateYearList(), _currentTime.year,
                            (dynamic value) {
                          setState(() {
                            _currentTime = DateTime(value ?? _currentTime.year,
                                _currentTime.month, _currentTime.day);
                          });
                          widget._onChange(_currentTime);
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(9),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: _size.height(35)),
                        _buildDaysHeader(_size),
                        SizedBox(height: _size.height(18)),
                        DottedLine(
                          dashColor: Colors.white,
                          dashGapColor: Colors.transparent,
                          dashGapLength: _size.width(3),
                          dashLength: _size.width(3),
                          lineThickness: 0.5,
                        ),
                        SizedBox(height: _size.height(7)),
                        _buildCustomCalendar(_size),
                        SizedBox(height: _size.height(50)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomCalendar(Size _size) {
    int startPoint = ConstData.listOfDays.keys
        .toList()
        .indexOf(DateTime(_currentTime.year, _currentTime.month, 1).weekday);
    DateTime startDate = DateTime(_currentTime.year, _currentTime.month, 1)
        .subtract(Duration(days: startPoint));
    return Container(
      height: _size.height(220),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 48 / 40,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: 35,
        itemBuilder: (ctx, index) => _buildDayCircle(
          _size,
          startDate.add(Duration(days: index)),
        ),
      ),
    );
  }

  Widget _buildDayCircle(
    Size _size,
    DateTime date,
  ) {
    return Container(
      width: _size.width(48),
      height: _size.height(30),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTime = DateTime(date.year, date.month, 1);
          });
          widget._onChange(date);
        },
        child: CircleAvatar(
          backgroundColor: widget._color(date),
          radius: _size.width(15),
          child: Text(
            date.day.toString(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: date.month != _currentTime.month
                      ? Colors.grey[350]
                      : widget._color(date) == Colors.white
                          ? ConstData.green_color
                          : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysHeader(Size _size) {
    List<Widget> list = [];
    ConstData.listOfDays.forEach(
      (key, value) {
        list.add(
          Container(
            width: _size.width(45),
            alignment: Alignment.center,
            child: Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue(value)
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontFamily: Get.find<AppLocalizationController>()
                                .currentLocale
                                .languageCode ==
                            "en"
                        ? "TTNorms"
                        : null,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
            ),
          ),
        );
      },
    );
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list);
  }

  Widget _buildDropDownButton(
    Size _size,
    Map<int, String> dropDownData,
    int value,
    void Function(int?) onChange,
  ) {
    return CustomDropdownButton<int>(
      maxHeight: _size.height(250),
      items: _buildMonthList(_size, dropDownData),
      buttonColor: Color.fromRGBO(0, 136, 75, 0.6),
      listColor: Color.fromRGBO(18, 164, 102, 1),
      borderRadius: _size.width(14),
      icon: SvgPicture.asset("assets/icons/arrow_down.svg"),
      onChange: onChange,
      value: value,
    );
  }

  List<CustomDropdownButtonItem<int>> _buildMonthList(
      Size _size, Map<int, String> dropDownData) {
    List<CustomDropdownButtonItem<int>> list = [];

    dropDownData.forEach(
      (key, value) {
        list.add(
          CustomDropdownButtonItem(
            child: Padding(
              padding: EdgeInsets.only(
                right: Get.find<AppLocalizationController>().isRTLanguage
                    ? _size.width(20)
                    : 0,
                left: !Get.find<AppLocalizationController>().isRTLanguage
                    ? _size.width(20)
                    : 0,
              ),
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(value)
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
              ),
            ),
            value: key,
          ),
        );
      },
    );
    return list;
  }
}
