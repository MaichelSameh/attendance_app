import 'package:attendance_app/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../api/employee_data_uploader_api.dart';
import '../../const/const_data.dart';
import '../../controllers/localization_controller.dart';
import '../../models/size.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_screen_header.dart';
import 'change_language_screen.dart';
import 'change_password_screen.dart';

class SettingScreen extends StatefulWidget {
  static const String route_name = "setting_screen";

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  bool _canAddLocation = false;

  EmployeeDataUploaderAPI _employeeDataUploaderAPI = EmployeeDataUploaderAPI();

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () async {
          _canAddLocation =
              await _employeeDataUploaderAPI.canAddBranch().catchError(
            (error) {
              print("SETTING_SCREEN build error: $error");
              _refreshController.refreshCompleted();
            },
          );
          setState(() {});
          _refreshController.refreshCompleted();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CustomScreenHeader("settings"),
            _buildCustomCard(
              size: _size,
              title: "language",
              trailing: Row(
                children: [
                  Text(
                    ConstData.supportedLanguages
                        .firstWhere((element) =>
                            element.languageCode ==
                            Get.find<AppLocalizationController>()
                                .currentLocale
                                .languageCode)
                        .languageCode
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(width: _size.width(10)),
                  Text(
                    ConstData.supportedLanguages
                        .firstWhere((element) =>
                            element.languageCode ==
                            Get.find<AppLocalizationController>()
                                .currentLocale
                                .languageCode)
                        .flag,
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ChangeLanguageScreen.route_name);
              },
            ),
            SizedBox(height: _size.height(20)),
            _buildCustomCard(
              size: _size,
              title: "change_password",
              trailing: SvgPicture.asset(
                "assets/icons/to_icon.svg",
                color: Color.fromRGBO(141, 141, 141, 1),
                width: _size.width(16),
                height: _size.height(12),
                matchTextDirection: true,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ChangePasswordScreen.route_name);
              },
            ),
            SizedBox(height: _size.height(20)),
            if (_canAddLocation)
              _buildCustomCard(
                size: _size,
                title: "add_branch",
                trailing: SvgPicture.asset(
                  "assets/icons/to_icon.svg",
                  color: Color.fromRGBO(141, 141, 141, 1),
                  width: _size.width(16),
                  height: _size.height(12),
                  matchTextDirection: true,
                ),
                onTap: () async {
                  await Navigator.pushNamed(
                      context, AddNewBranchScreen.route_name);
                  _refreshController.requestRefresh();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard({
    required Size size,
    required String title,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        width: 398,
        height: 119,
        shadows: [],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Get.find<AppLocalizationController>().getTranslatedValue(title),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              trailing ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
