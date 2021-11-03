import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/report_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';
import 'add_report_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  static const String route_name = "report_details_screen";

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late ReportInfo report;
  bool _firstTime = true;
  void _openFile(String fileLink, String fileName, BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => PreLoader(),
      barrierDismissible: false,
    );
    //fetching the image from the internet
    http.Response res = await http.get(Uri.parse(fileLink));
    //getting the app directory to store the image in
    Directory documentDirectory = await getTemporaryDirectory();
    //getting the images directory
    final String filePath = documentDirectory.path + "/files";
    //creating the images directory
    await Directory(filePath).create(recursive: true);
    //creating the image file
    File file = File(filePath + "/" + fileName);
    //writing the image
    file.writeAsBytesSync(res.bodyBytes);
    Navigator.pop(context);
    OpenFile.open(filePath + "/" + fileName);
  }

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      report = ModalRoute.of(context)!.settings.arguments as ReportInfo;
      _firstTime = false;
    }
    Size _size = Size(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomScreenHeader("report"),
            CustomCard(
              width: 368,
              child: Column(
                children: [
                  CustomTitleHeader(
                    width: 368,
                    // height: 91,
                    subTitle: DateFormat("dd MM, yyyy").format(report.date),
                    title: report.title,
                    leading: SvgPicture.asset(
                      "assets/icons/report_icon.svg",
                      width: _size.width(42),
                      height: _size.height(49),
                    ),
                    backgroundColor: Color.fromRGBO(11, 81, 145, 1),
                  ),
                  SizedBox(height: _size.height(35)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(48),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          report.description,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Color.fromRGBO(168, 167, 167, 1),
                                    fontSize: 12,
                                  ),
                        ),
                        SizedBox(height: _size.height(30)),
                        if (report.file != null)
                          GestureDetector(
                            onTap: () => _openFile(
                              report.file!,
                              report.fileName!,
                              context,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/file_link.svg",
                                  width: _size.width(13),
                                  height: 18,
                                ),
                                SizedBox(width: _size.width(7)),
                                if (report.fileName != null)
                                  Text(
                                    report.fileName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromRGBO(11, 81, 145, 1),
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        _buildEditButtons(_size, context, report.canEdit),
                        SizedBox(height: _size.height(25)),
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
                    bool deleted =
                        await uploader.deleteReport(report.id).catchError(
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
                    width: _size.width(125),
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
                    if (report.file != null) {
                      showDialog(
                        context: context,
                        builder: (_) => PreLoader(),
                        barrierDismissible: false,
                      );
                      //fetching the image from the internet
                      http.Response res =
                          await http.get(Uri.parse(report.file!));
                      //getting the app directory to store the image in
                      Directory documentDirectory =
                          await getTemporaryDirectory();
                      //getting the images directory
                      final String filePath = documentDirectory.path + "/files";
                      //creating the images directory
                      await Directory(filePath).create(recursive: true);
                      //creating the image file
                      File file = File(filePath +
                          "/" +
                          "report.${report.file!.split(".").last}");
                      //writing the image
                      file.writeAsBytesSync(res.bodyBytes);
                      report.setFilePath(filePath +
                          "/" +
                          "report.${report.file!.split(".").last}");
                      Navigator.pop(context);
                    }
                    report = await Navigator.pushNamed(
                      context,
                      AddReportScreen.route_name,
                      arguments: report,
                    ) as ReportInfo;
                    setState(() {});
                  },
                  width: 125,
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
