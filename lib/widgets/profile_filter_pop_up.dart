import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/localization_controller.dart';
import '../models/size.dart';
import 'widgets.dart';

class ProfileFilterPopUp extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  const ProfileFilterPopUp(this.startDate, this.endDate);

  @override
  _ProfileFilterPopUpState createState() => _ProfileFilterPopUpState();
}

class _ProfileFilterPopUpState extends State<ProfileFilterPopUp> {
  DateTime startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month - 1,
    DateTime.now().day,
  );
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  List<int> generateNumbers(int start, int end) {
    List<int> result = [];
    for (int i = start; i < end; i++) {
      result.add(i);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Center(
      child: Container(
        width: _size.width(362),
        height: _size.height(500),
        padding: EdgeInsets.symmetric(
          horizontal: _size.width(34),
          vertical: _size.height(33),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_size.width(43)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop({
                      "start_date": startDate,
                      "end_date": endDate,
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(_size.width(10)),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/icons/back_arrow.svg",
                        color: ConstData.green_color,
                        width: _size.width(18),
                        height: _size.height(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: _size.width(50)),
                Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue("filter")
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 12, 46, 1),
                      ),
                ),
              ],
            ),
            SizedBox(height: _size.height(38)),
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("from")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(112, 112, 112, 1),
                  ),
            ),
            SizedBox(height: _size.height(15)),
            _buildDateSelector(true, _size),
            SizedBox(height: _size.height(30)),
            Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("to")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(112, 112, 112, 1),
                  ),
            ),
            SizedBox(height: _size.height(15)),
            _buildDateSelector(false, _size),
            Spacer(),
            CustomElevatedButton(
              onTap: () {
                Navigator.pop(context, {
                  "start_date": startDate,
                  "end_date": endDate,
                });
              },
              width: double.infinity,
              height: _size.height(61),
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("filter")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
              ),
            ),
            SizedBox(height: _size.height(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(bool startDate, Size _size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdownButton(
          startDate ? this.startDate.day : this.endDate.day,
          generateNumbers(
              1,
              DateTime(
                      startDate ? this.startDate.year : this.endDate.year,
                      startDate
                          ? this.startDate.month + 1
                          : this.endDate.month + 1,
                      1)
                  .subtract(Duration(days: 1))
                  .day),
          (value) {
            setState(
              () {
                if (startDate) {
                  this.startDate = DateTime(
                    this.startDate.year,
                    this.startDate.month,
                    value,
                  );
                } else {
                  this.endDate = DateTime(
                    this.endDate.year,
                    this.endDate.month,
                    value,
                  );
                }
              },
            );
          },
          _size,
        ),
        _buildDropdownButton(
          startDate ? this.startDate.month : this.endDate.month,
          generateNumbers(0, 12),
          (value) {
            setState(
              () {
                if (startDate) {
                  this.startDate = DateTime(
                    this.startDate.year,
                    value,
                    this.startDate.day,
                  );
                } else {
                  this.endDate = DateTime(
                    this.endDate.year,
                    value,
                    this.endDate.day,
                  );
                }
              },
            );
          },
          _size,
        ),
        _buildDropdownButton(
          startDate ? this.startDate.year : this.endDate.year,
          generateNumbers(DateTime.now().year - 5, DateTime.now().year + 5),
          (value) {
            setState(
              () {
                if (startDate) {
                  this.startDate = DateTime(
                    value,
                    this.startDate.month,
                    this.startDate.day,
                  );
                } else {
                  this.endDate = DateTime(
                    value,
                    this.endDate.month,
                    this.endDate.day,
                  );
                }
              },
            );
          },
          _size,
        ),
      ],
    );
  }

  Widget _buildDropdownButton(
    int value,
    List<int> items,
    void Function(dynamic) onChange,
    Size _size,
  ) {
    return CustomDropdownButton<int>(
      height: _size.height(48),
      width: _size.width(90),
      maxHeight: _size.height(300),
      buttonColor: Color.fromRGBO(236, 238, 244, 1),
      borderRadius: _size.width(14),
      padding: EdgeInsets.symmetric(horizontal: _size.width(11)),
      value: value,
      items: items
          .map<CustomDropdownButtonItem<int>>(
              (element) => _buildDropdownItem(element))
          .toList(),
      onChange: onChange,
      icon: SvgPicture.asset(
        "assets/icons/arrow_down.svg",
        color: Color.fromRGBO(196, 198, 204, 1),
        width: _size.width(15),
        height: _size.height(9),
      ),
    );
  }

  CustomDropdownButtonItem<int> _buildDropdownItem(int value) {
    return CustomDropdownButtonItem(
      value: value,
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 16,
              color: Color.fromRGBO(196, 198, 204, 1),
            ),
      ),
    );
  }
}
