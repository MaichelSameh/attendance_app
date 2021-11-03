import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/size.dart';
import '../../../models/vacation_info.dart';
import '../../../widgets/widgets.dart';
import 'request_new_vacation_screen.dart';

class VacationDetailsScreen extends StatefulWidget {
  static const String route_name = "vacation_details_screen";

  @override
  _VacationDetailsScreenState createState() => _VacationDetailsScreenState();
}

class _VacationDetailsScreenState extends State<VacationDetailsScreen> {
  late VacationInfo vacation;
  bool _firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      vacation = ModalRoute.of(context)!.settings.arguments as VacationInfo;
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
              child: Padding(
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
                      children: [PermissionStateCard(vacation.state, false)],
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
                        left: Get.find<AppLocalizationController>().isRTLanguage
                            ? 0
                            : _size.width(20),
                        right:
                            !Get.find<AppLocalizationController>().isRTLanguage
                                ? 0
                                : _size.width(20),
                      ),
                      child: SelectableText(
                        vacation.description,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Color.fromRGBO(168, 167, 167, 1),
                              fontSize: 12,
                            ),
                      ),
                    ),
                    _buildEditButtons(_size, context, vacation.canEdit),
                    SizedBox(height: _size.height(42)),
                  ],
                ),
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

  Widget _buildEditButtons(Size _size, BuildContext context, bool canEdit) {
    return canEdit
        ? Padding(
            padding: EdgeInsets.only(
              top: _size.height(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (ConnectivityResult.none == connectivityResult) {
                      showNoInternetMessage(context);
                      return;
                    }
                    EmployeeDataUploaderAPI uploader =
                        EmployeeDataUploaderAPI();
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => PreLoader(),
                    );
                    bool deleted = await uploader
                        .deleteVacation(vacation.id.toString())
                        .catchError(
                      (error) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                        return false;
                      },
                    );
                    Navigator.pop(context);
                    if (deleted) {
                      Navigator.pop(context, VacationInfo.empty());
                    }
                  },
                  child: Container(
                    width: _size.width(150),
                    height: _size.height(52),
                    alignment: Alignment.center,
                    child: Text(
                      Get.find<AppLocalizationController>()
                          .getTranslatedValue("delete")
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Color.fromRGBO(255, 100, 100, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                CustomElevatedButton(
                  onTap: () async {
                    vacation = await Navigator.pushNamed(
                      context,
                      RequestNewVacationScreen.route_name,
                      arguments: vacation,
                    ) as VacationInfo;
                    setState(() {});
                  },
                  width: 150,
                  height: 52,
                  child: Text(
                    Get.find<AppLocalizationController>()
                        .getTranslatedValue("edit")
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
