import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../const/const_data.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/report_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class ManagerReportDetailsScreen extends StatefulWidget {
  static const String route_name = "manager_report_details_screen";

  @override
  _ManagerReportDetailsScreenState createState() =>
      _ManagerReportDetailsScreenState();
}

class _ManagerReportDetailsScreenState
    extends State<ManagerReportDetailsScreen> {
  late Map<String, dynamic> data;
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
      data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      report = data["report"];
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
                  CustomProfileHeader(
                    employee: data["employee"],
                  ),
                  SizedBox(height: _size.height(27)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _size.width(48),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: ConstData.report_color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        Text(
                          DateFormat("dd ").format(report.date) +
                              Get.find<AppLocalizationController>()
                                  .getTranslatedValue(ConstData
                                      .listOfMonths[report.date.month]!)
                                  .toUpperCase() +
                              DateFormat(", yyyy").format(report.date),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: ConstData.report_color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        SizedBox(height: _size.height(27)),
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
}
