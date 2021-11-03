import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../api/employee_data_api.dart';
import '../api/manager_data_api.dart';
import '../const/const_data.dart';
import '../controllers/localization_controller.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  static const String route_name = "profile_screen";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  EmployeeDataAPI _employeeDataAPI = EmployeeDataAPI();
  // ignore: unused_field
  double _padding = 0;
  DateTime _endDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));

  EmployeeInfo _employee = EmployeeInfo.empty();

  int id = 0;

  Future<void> fetchProfileImage() async {
    ManagerDataAPI _managerDataAPI = ManagerDataAPI();

    _employee = await _managerDataAPI.fetchEmployeeInfo(id.toString());
    setState(() {});
  }

  bool _firstBuild = true;
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    if (_firstBuild) {
      id = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
      _firstBuild = false;
      if (id != 0) fetchProfileImage();
      setState(() {});
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: _size.height(220),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ConstData.green_gradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(577, 276),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _size.height(77)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _size.width(37)),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: _size.height(16),
                    child: SvgPicture.asset(
                      "assets/icons/back_arrow.svg",
                      width: _size.width(20),
                      height: _size.height(16),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: _size.height(60)),
              Center(
                child: id == 0
                    ? GestureDetector(
                        onTap: () async {
                          if (id == 0) {
                            showDialog(
                              context: context,
                              builder: (_) => CustomPopUpMessage(
                                header: Text(
                                  Get.find<AppLocalizationController>()
                                      .getTranslatedValue("profile_options"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                ),
                                actions: [
                                  CustomElevatedButton(
                                    onTap: () async {
                                      XFile? image = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (image != null) {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) => PreLoader(),
                                        );
                                        await _employeeDataAPI
                                            .updateProfilePicture(
                                                File(image.path))
                                            .catchError(
                                          (error) {
                                            FocusScope.of(context).unfocus();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(error.toString()),
                                              ),
                                            );
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        );
                                        setState(() {});
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              Get.find<
                                                      AppLocalizationController>()
                                                  .getTranslatedValue(
                                                "no_selected_image",
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    width: 134,
                                    height: 50,
                                    child: Text(
                                      Get.find<AppLocalizationController>()
                                          .getTranslatedValue("select_image"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  CustomElevatedButton(
                                    onTap: () async {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => PreLoader(),
                                      );
                                      await _employeeDataAPI
                                          .updateProfilePicture(null)
                                          .catchError(
                                        (error) {
                                          FocusScope.of(context).unfocus();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(error.toString()),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                      );
                                      setState(() {});
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    color: ConstData.failure_color,
                                    width: 134,
                                    height: 50,
                                    child: Text(
                                      Get.find<AppLocalizationController>()
                                          .getTranslatedValue("delete"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        child: ProfilePicture(color: Colors.black),
                      )
                    : ProfilePicture(
                        color: Colors.black,
                        name: _employee.name,
                        role: _employee.role,
                        imageURL: _employee.profilePictureLink,
                      ),
              ),
              SizedBox(height: _size.height(20)),
              _buildProfileFilter(_size, context),
              _buildProfileCards(_size),
            ],
          ),
        ],
      ),
    );
  }

  Expanded _buildProfileCards(Size _size) {
    ManagerDataAPI _managerDataAPI = ManagerDataAPI();
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: _size.width(35),
          right: _size.width(35),
          top: _size.height(30),
        ),
        child: FutureBuilder(
          future: id == 0
              ? _employeeDataAPI.fetchProfileData(
                  _startDate,
                  _endDate,
                )
              : _managerDataAPI.fetchEmployeeProfileData(
                  id,
                  _startDate,
                  _endDate,
                ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return PreLoader();
            if (snapshot.hasData) {
              List<Map<String, String>> list =
                  snapshot.data as List<Map<String, String>>;
              return GridView(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 160 / 202,
                  crossAxisSpacing: 40,
                  mainAxisExtent: 202,
                  mainAxisSpacing: 25,
                ),
                children: list
                    .map(
                      (e) => ProfileWorkCard(
                        titleKey: e.keys.first,
                        subTitle: e.values.first,
                      ),
                    )
                    .toList(),
              );
            }
            return Center(child: Text("No data found"));
          },
        ),
      ),
    );
  }

  Widget _buildProfileFilter(Size _size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _size.width(34)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomElevatedButton(
            onTap: () async {
              Map<String, DateTime> map = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => ProfileFilterPopUp(_startDate, _endDate),
              );
              if (map.isNotEmpty) {
                _startDate = map["start_date"]!;
                _endDate = map["end_date"]!;
                setState(() {});
              }
            },
            color: Color.fromRGBO(236, 238, 244, 1),
            width: _size.width(133),
            height: _size.height(48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue("filter")
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Color.fromRGBO(196, 198, 204, 1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SvgPicture.asset(
                  "assets/icons/filter_icon.svg",
                  width: _size.width(30),
                  height: _size.height(29),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
