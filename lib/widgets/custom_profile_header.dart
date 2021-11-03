import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/employee_info.dart';
import '../models/size.dart';

class CustomProfileHeader extends StatelessWidget {
  late final EmployeeInfo _employee;
  late final Color _color;
  late final List<BoxShadow> _shadow;
  CustomProfileHeader({
    required EmployeeInfo employee,
    Color? color,
    List<BoxShadow>? shadow,
  }) {
    this._employee = employee;
    this._color = color ?? Color.fromRGBO(234, 235, 239, 1);
    this._shadow = shadow ??
        [
          BoxShadow(
            color: Color.fromRGBO(226, 226, 226, 0.16),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ];
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Container(
      height: _size.height(110),
      width: double.infinity,
      padding: EdgeInsets.only(
        left: _size.width(27),
        right: _size.width(27),
        bottom: _size.height(8),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color,
        boxShadow: _shadow,
        borderRadius: BorderRadius.circular(_size.width(41)),
      ),
      child: Row(
        children: [
          Container(
            width: _size.width(62),
            height: _size.width(62),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_size.width(48)),
              child: Image.network(
                _employee.profilePictureLink,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) {
                  return Image.asset(
                    "assets/images/profile_avatar.png",
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: _size.width(21)),
          Container(
            width: _size.width(230),
            alignment: Get.find<AppLocalizationController>().isRTLanguage
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _employee.name,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  _employee.role,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(84, 89, 101, 0.8),
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
