import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../api/employee_data_uploader_api.dart';
import '../../../controllers/localization_controller.dart';
import '../../../models/report_info.dart';
import '../../../models/size.dart';
import '../../../widgets/widgets.dart';

class AddReportScreen extends StatefulWidget {
  static const String route_name = "add_report_screen";

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final EmployeeDataUploaderAPI _uploader = EmployeeDataUploaderAPI();

  TextEditingController _description = TextEditingController();
  TextEditingController _title = TextEditingController();

  String _filePath = "";
  ReportInfo report = ReportInfo.empty();
  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (firstTime) {
      report = ModalRoute.of(context)!.settings.arguments as ReportInfo;
      _filePath = report.file ?? "";
      _description.text = report.description;
      _title.text = report.title;
      firstTime = false;
    }
    Size _size = Size(context);
    return Scaffold(
      body: Column(
        children: [
          CustomScreenHeader("add_new_report"),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: _size.width(43)),
              children: [
                CustomTextField(
                  hintKey: "report_title",
                  headerKey: "report_title",
                  height: 72,
                  width: 343,
                  controller: _title,
                  padding: EdgeInsets.symmetric(
                    horizontal: _size.width(17),
                  ),
                ),
                SizedBox(height: _size.height(20)),
                CustomTextField(
                  hintKey: "report_description",
                  headerKey: "report_description",
                  height: 217,
                  expands: true,
                  width: 343,
                  controller: _description,
                  keyboardType: TextInputType.multiline,
                  padding: EdgeInsets.all(_size.width(14)),
                ),
                SizedBox(height: _size.height(20)),
                if (_filePath.isNotEmpty)
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/file_link.svg",
                        width: _size.width(13),
                        height: 18,
                      ),
                      SizedBox(width: _size.width(7)),
                      Container(
                        width: _size.width(300),
                        child: Text(
                          _filePath.split("/").last,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(11, 81, 145, 1),
                                  ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: _size.height(15)),
                _buildAttachFileButton(_size),
                SizedBox(height: _size.height(34)),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CustomElevatedButton _buildSubmitButton() {
    return CustomElevatedButton(
      onTap: () async {
        FocusScope.of(context).unfocus();
        if (_description.text.isEmpty && _filePath.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Get.find<AppLocalizationController>()
                  .getTranslatedValue("empty_fields_message")),
            ),
          );
        } else {
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
          ReportInfo uploaded = await _uploader
              .addReport(
            _title.text,
            _description.text,
            file: _filePath.isEmpty ? null : File(_filePath),
            id: report.id,
            edit: report.canEdit,
          )
              .catchError(
            (error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
            },
          );
          Navigator.pop(context);
          if (uploaded.id != ReportInfo.empty().id) {
            Navigator.of(context).pop(uploaded);
          }
        }
      },
      width: 344,
      height: 72,
      child: Text(
        Get.find<AppLocalizationController>().getTranslatedValue("add_report"),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Row _buildAttachFileButton(Size _size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomElevatedButton(
          onTap: () async {
            setState(() {
              _filePath = "";
            });
            FilePickerResult? file = await FilePicker.platform.pickFiles();
            if (file != null) {
              setState(() {
                _filePath = file.files.single.path ?? "";
              });
            }
          },
          width: 158,
          height: 55,
          color: Color.fromRGBO(236, 238, 244, 1),
          child: Row(
            children: [
              SizedBox(width: _size.width(20)),
              SvgPicture.asset(
                'assets/icons/file_link.svg',
                color: Color.fromRGBO(198, 196, 196, 1),
                width: _size.width(12),
                height: _size.height(16),
              ),
              SizedBox(width: _size.width(7)),
              Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("attach_file"),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Color.fromRGBO(198, 196, 196, 1),
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
