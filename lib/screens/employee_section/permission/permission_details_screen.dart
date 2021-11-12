import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/permission_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';
import 'request_new_permission_screen.dart';

class PermissionDetailsScreen extends StatefulWidget {
  static const String route_name = "permission_details_screen";

  @override
  _PermissionDetailsScreenState createState() =>
      _PermissionDetailsScreenState();
}

class _PermissionDetailsScreenState extends State<PermissionDetailsScreen> {
  late PermissionInfo permission;

  bool _firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      permission = ModalRoute.of(context)!.settings.arguments as PermissionInfo;
      _firstTime = false;
    }
    Size _size = Size(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomScreenHeader("permission_request"),
            CustomCard(
              width: 368,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _size.width(31),
                  vertical: _size.height(37),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 0, width: double.infinity),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [PermissionStateCard(permission.state, false)],
                    ),
                    SizedBox(height: _size.height(26)),
                    _buildFieldName(
                      _size,
                      "vacation_icon",
                      "reason",
                      11,
                      14,
                    ),
                    _buildField(_size, permission.permissionType),
                    _buildFieldName(
                      _size,
                      "calendar",
                      "date",
                      13,
                      12,
                    ),
                    _buildField(
                      _size,
                      DateFormat("dd MM, yyyy").format(permission.dateTime),
                    ),
                    _buildFieldName(
                      _size,
                      "delay_icon",
                      "time",
                      14,
                      14,
                    ),
                    _buildField(
                      _size,
                      DateFormat(Get.find<AppLocalizationController>()
                                      .isRTLanguage
                                  ? "mm : hh"
                                  : "hh : mm")
                              .format(permission.dateTime) +
                          " " +
                          (Get.find<AppLocalizationController>()
                              .getTranslatedValue(
                                  permission.dateTime.hour > 12 ? "pm" : "am")),
                    ),
                    _buildFieldName(
                      _size,
                      "description",
                      "description",
                      12,
                      12,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            permission.description,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Color.fromRGBO(168, 167, 167, 1),
                                      fontSize: 12,
                                    ),
                          ),
                          _buildEditButtons(_size, context, permission.canEdit),
                          SizedBox(height: _size.height(25)),
                        ],
                      ),
                    ),
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

  Widget _buildFieldName(
    Size _size,
    String iconName,
    String titleKey,
    double height,
    double width,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/icons/$iconName.svg",
          color: Colors.black,
          height: _size.height(height),
          width: _size.height(width),
        ),
        SizedBox(width: _size.width(10)),
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
                        .deletePermission(permission.id.toString())
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
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: _size.width(130),
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
                    PermissionInfo temp = await Navigator.pushNamed(
                      context,
                      RequestNewPermissionScreen.route_name,
                      arguments: permission,
                    ) as PermissionInfo;
                    print(temp);
                    permission = temp;
                    setState(() {});
                  },
                  width: 130,
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
