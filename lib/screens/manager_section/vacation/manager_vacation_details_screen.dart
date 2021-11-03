import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/manager_data_api.dart';
import '../../../const/const_data.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/permission_info.dart';
import '../../../models/size.dart';
import '../../../models/vacation_info.dart';
import '../../../widgets/widgets.dart';

class ManagerVacationDetailsScreen extends StatefulWidget {
  static const String route_name = "manager_vacation_details_screen";

  @override
  _ManagerVacationDetailsScreenState createState() =>
      _ManagerVacationDetailsScreenState();
}

class _ManagerVacationDetailsScreenState
    extends State<ManagerVacationDetailsScreen> {
  late Map<String, dynamic> data;
  late final VacationInfo vacation;
  bool _firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      vacation = data["vacation"];
      _firstTime = false;
    }
    Size _size = Size(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomScreenHeader("vacation_request"),
            CustomCard(
              width: 368,
              child: Column(
                children: [
                  CustomProfileHeader(
                    employee: data["employee"],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(31),
                      vertical: _size.height(37),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0, width: double.infinity),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PermissionStateCard(vacation.state, false)
                          ],
                        ),
                        SizedBox(height: _size.height(26)),
                        _buildFieldName(
                          size: _size,
                          iconName: "vacation_icon",
                          titleKey: "reason",
                          height: 11,
                          width: 14,
                        ),
                        _buildField(_size, vacation.reason),
                        _buildFieldName(
                          size: _size,
                          iconName: "calendar",
                          titleKey: "from_date",
                          height: 13,
                          width: 12,
                        ),
                        _buildField(
                          _size,
                          DateFormat("dd MM, yyyy").format(vacation.startDate),
                        ),
                        _buildFieldName(
                          size: _size,
                          iconName: "calendar",
                          titleKey: "to_date",
                          height: 13,
                          width: 12,
                        ),
                        _buildField(
                          _size,
                          DateFormat("dd MM, yyyy").format(vacation.endDate),
                        ),
                        _buildFieldName(
                          size: _size,
                          iconName: "description",
                          titleKey: "description",
                          height: 12,
                          width: 12,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: _size.height(3),
                            left: Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? 0
                                : _size.width(20),
                            right: !Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? 0
                                : _size.width(20),
                          ),
                          child: SelectableText(
                            vacation.description,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Color.fromRGBO(168, 167, 167, 1),
                                      fontSize: 12,
                                    ),
                          ),
                        ),
                        _buildDecisionButtons(_size, vacation.state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _size.height(50)),
          ],
        ),
      ),
    );
  }

  Padding _buildField(Size _size, String text) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.find<AppLocalizationController>().isRTLanguage
            ? 0
            : _size.width(20),
        right: !Get.find<AppLocalizationController>().isRTLanguage
            ? 0
            : _size.width(20),
        top: _size.height(3),
        bottom: _size.height(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Color.fromRGBO(168, 167, 167, 1),
            ),
      ),
    );
  }

  Widget _buildFieldName({
    required Size size,
    required String iconName,
    required String titleKey,
    required double height,
    required double width,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/icons/$iconName.svg",
          color: Colors.black,
          height: size.height(height),
          width: size.height(width),
        ),
        SizedBox(width: size.width(10)),
        Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue(titleKey)
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ],
    );
  }

  Widget _buildDecisionButtons(Size _size, PermissionState state) {
    ManagerDataAPI _managerDataAPI = ManagerDataAPI();
    return state == PermissionState.Pending
        ? Padding(
            padding: EdgeInsets.only(
              top: _size.height(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomElevatedButton(
                  onTap: () {
                    _managerDataAPI
                        .updateVacation(
                      vacation.id,
                      RequestStatus.Accepted,
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
                  },
                  width: 134,
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("Accept")
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: _size.width(9)),
                      SvgPicture.asset(
                        "assets/icons/true_sign.svg",
                        color: Colors.white,
                        width: _size.width(20),
                        height: _size.height(12),
                      ),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onTap: () async {
                    _managerDataAPI
                        .updateVacation(
                      vacation.id,
                      RequestStatus.Rejected,
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
                  },
                  width: 134,
                  height: 52,
                  color: ConstData.failure_color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("reject")
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: _size.width(9)),
                      SvgPicture.asset(
                        "assets/icons/cross.svg",
                        color: Colors.white,
                        width: _size.width(14),
                        height: _size.height(14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
