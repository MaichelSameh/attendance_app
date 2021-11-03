import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/size.dart';
import 'no_connection_message.dart';
import 'widgets.dart';

class StartWorkButton extends StatefulWidget {
  @override
  _StartWorkButtonState createState() => _StartWorkButtonState();
}

class _StartWorkButtonState extends State<StartWorkButton> {
  final double _maxRadius = 120;

  final double _minRadius = 70;

  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    final List<Map<String, void Function()>> buttons = [
      {
        "start_your_work": () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => PreLoader(),
          );
          bool finish = await Get.find<HomeController>().startWork().catchError(
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
          if (finish) {}
        },
      },
      {
        "finish_work": () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          showDialog(
            context: context,
            builder: (context) {
              return CustomPopUpMessage(
                title: SvgPicture.asset(
                    "assets/icons/finish_work_illustrator.svg"),
                contentKey: "finish_work_message",
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: _size.width(156),
                      height: _size.height(52),
                      alignment: Alignment.center,
                      child: Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("cancel"),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: ConstData.green_color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  CustomElevatedButton(
                    onTap: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (ConnectivityResult.none == connectivityResult) {
                        showNoInternetMessage(context);
                        return;
                      }
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => PreLoader());
                      bool finish = await Get.find<HomeController>()
                          .finishWork()
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
                      if (finish) {
                        Navigator.pop(context);
                      }
                    },
                    width: 156,
                    height: 52,
                    child: Text(
                      Get.find<AppLocalizationController>().getTranslatedValue(
                        "finish",
                      ),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      },
      {
        "visit_client": () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          showDialog(
              context: context,
              builder: (_) {
                return CustomPopUpMessage(
                  header: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: _size.width(10),
                            bottom: _size.width(10),
                            left: !Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? _size.width(10)
                                : 0,
                            right: Get.find<AppLocalizationController>()
                                    .isRTLanguage
                                ? _size.width(10)
                                : 0,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/back_arrow.svg",
                            color: ConstData.green_color,
                            width: _size.width(18),
                            height: _size.height(15),
                          ),
                        ),
                      ),
                      SizedBox(width: _size.width(32)),
                      Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("client_information")
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  body: Container(
                    height: _size.height(108),
                    child: CustomTextField(
                      hintKey: "client_name",
                      prefixIconName: "person",
                      controller: _nameController,
                      headerKey: "client_name",
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: _size.height(70),
                        bottom: _size.height(35),
                      ),
                      child: CustomElevatedButton(
                        width: 340,
                        height: 72,
                        child: Text(
                          Get.find<AppLocalizationController>()
                              .getTranslatedValue("save_continue")
                              .toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                        ),
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (ConnectivityResult.none == connectivityResult) {
                            showNoInternetMessage(context);
                            return;
                          }
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => PreLoader(),
                          );
                          bool finish = await Get.find<HomeController>()
                              .visitClient(_nameController.text)
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
                          if (finish) {
                            Navigator.pop(context);
                            _nameController.clear();
                          }
                        },
                      ),
                    )
                  ],
                );
              });
        },
      },
      {
        "meet_client": () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          if (Get.find<UserController>().currentUser.needCamera) {
            showDialog(
              context: context,
              builder: (context) {
                return CustomPopUpMessage(
                  title: SvgPicture.asset(
                      "assets/icons/open_camera_illustartor.svg"),
                  contentKey: "open_camera_reason",
                  actions: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: _size.width(156),
                        height: _size.height(52),
                        alignment: Alignment.center,
                        child: Text(
                          Get.find<AppLocalizationController>()
                              .getTranslatedValue("cancel"),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: ConstData.green_color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                        ),
                      ),
                    ),
                    CustomElevatedButton(
                      onTap: () async {
                        var connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (ConnectivityResult.none == connectivityResult) {
                          showNoInternetMessage(context);
                          return;
                        }
                        XFile? image = await ImagePicker()
                            .pickImage(source: ImageSource.camera)
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
                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Get.find<AppLocalizationController>()
                                    .getTranslatedValue("no_image_captured"),
                              ),
                            ),
                          );
                          return;
                        }
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => PreLoader(),
                        );
                        bool finish = await Get.find<HomeController>()
                            .meetClient(
                          File(image.path),
                        )
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
                        if (finish) {
                          Navigator.pop(context);
                        }
                      },
                      width: 156,
                      height: 52,
                      child: Text(
                        Get.find<AppLocalizationController>()
                            .getTranslatedValue("open_camera"),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => PreLoader(),
            );
            bool finish = await Get.find<HomeController>().meetClient(
              null,
            );
            Navigator.pop(context);
            if (finish) {}
          }
        },
      },
      {
        "end_visit": () async {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (ConnectivityResult.none == connectivityResult) {
            showNoInternetMessage(context);
            return;
          }
          showDialog(
            context: context,
            builder: (_) {
              return CustomPopUpMessage(
                contentAndTitleDistance: 21,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/end_visit_illustrator.svg",
                    ),
                    SizedBox(height: _size.height(10)),
                    Text(
                      Get.find<AppLocalizationController>()
                              .getTranslatedValue("all_done")
                              .toUpperCase() +
                          "!",
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: ConstData.green_color,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                contentKey: "next_Station_question",
                actions: [
                  Container(
                    height: _size.height(130),
                    width: _size.width(340),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomElevatedButton(
                          onTap: () async {
                            var connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (ConnectivityResult.none == connectivityResult) {
                              showNoInternetMessage(context);
                              return;
                            } else
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => PreLoader(),
                              );
                            bool finish = await Get.find<HomeController>()
                                .endVisit("client_visit")
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
                            if (finish) {
                              Navigator.pop(context);
                            }
                          },
                          width: _size.width(320),
                          height: 52,
                          child: Text(
                            Get.find<AppLocalizationController>()
                                .getTranslatedValue(
                              "another_client",
                            ),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
                                if (ConnectivityResult.none ==
                                    connectivityResult) {
                                  showNoInternetMessage(context);
                                  return;
                                } else
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => PreLoader(),
                                  );
                                bool finish = await Get.find<HomeController>()
                                    .endVisit("finish_work")
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
                                if (finish) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                height: _size.height(52),
                                alignment: Alignment.center,
                                child: Text(
                                  Get.find<AppLocalizationController>()
                                      .getTranslatedValue(
                                    "finish_work",
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        color: ConstData.green_color,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
                                if (ConnectivityResult.none ==
                                    connectivityResult) {
                                  showNoInternetMessage(context);
                                  return;
                                } else
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => PreLoader(),
                                  );
                                bool finish = await Get.find<HomeController>()
                                    .endVisit("company")
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
                                if (finish) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                height: _size.height(52),
                                alignment: Alignment.center,
                                child: Text(
                                  Get.find<AppLocalizationController>()
                                      .getTranslatedValue("company"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        color: ConstData.green_color,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      },
    ];
    return GetBuilder<UserController>(
      builder: (userController) => Column(
        children: [
          StartWorkButtonBackground(
              maxRadius: _maxRadius,
              minRadius: _minRadius,
              layersCount: 3,
              colors: [
                Color.fromRGBO(249, 248, 251, 0.6),
                Color.fromRGBO(249, 248, 251, 0.7),
                Color.fromRGBO(249, 248, 251, 1),
              ],
              child: _buildButton(
                userController.currentUser.canStartWork
                    ? buttons[0]
                    : userController.currentUser.canStartClientMeeting
                        ? buttons[3]
                        : userController.currentUser.canStartClientVisit
                            ? buttons[2]
                            : userController.currentUser.canEndClientVisit
                                ? buttons[4]
                                : userController.currentUser.canEndWork
                                    ? buttons[1]
                                    : {"no_action": () {}},
                _size,
              )),
          if (userController.currentUser.canStartWork &&
              (userController.currentUser.canStartClientMeeting ||
                  userController.currentUser.canEndClientVisit ||
                  userController.currentUser.canStartClientVisit))
            SizedBox(height: _size.height(30)),
          userController.currentUser.canStartWork &&
                  (userController.currentUser.canStartClientMeeting ||
                      userController.currentUser.canEndClientVisit ||
                      userController.currentUser.canStartClientVisit)
              ? _finishWorkButton(
                  _size,
                  context,
                  buttons
                      .firstWhere(
                          (element) => element.containsKey("finish_work"))
                      .values
                      .first,
                  "finish_work")
              : SizedBox(height: _size.height(20)),
        ],
      ),
    );
  }

  Widget _buildButton(Map<String, void Function()> buttonData, Size _size) {
    return buttonData.isEmpty
        ? Container()
        : GestureDetector(
            onTap: buttonData.values.first,
            child: CircleAvatar(
              radius: _size.width(_minRadius),
              backgroundColor: Colors.transparent,
              child: Container(
                width: _size.width(
                    buttonData.keys.first == "start_your_work" ? 130 : 80),
                alignment: Alignment.center,
                child: Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue(buttonData.keys.first),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
  }

  Widget _finishWorkButton(
      Size _size, BuildContext context, void Function() onTap, String key) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Text(
          Get.find<AppLocalizationController>().getTranslatedValue(key),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
