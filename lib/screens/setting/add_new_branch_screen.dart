import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../api/employee_data_uploader_api.dart';
import '../../const/const_data.dart';
import '../../controllers/localization_controller.dart';
import '../../models/size.dart';
import '../../widgets/widgets.dart';

class AddNewBranchScreen extends StatefulWidget {
  static const String route_name = "add_new_branch_screen";

  @override
  _AddNewBranchScreenState createState() => _AddNewBranchScreenState();
}

class _AddNewBranchScreenState extends State<AddNewBranchScreen> {
  TextEditingController _branchName = TextEditingController();
  TextEditingController _branchPhoneNumber = TextEditingController();

  bool validate() {
    return _branchPhoneNumber.text.isNotEmpty &&
        _branchPhoneNumber.text.isNotEmpty &&
        _latitude.isNotEmpty &&
        _longitude.isNotEmpty;
  }

  String _latitude = "";
  String _longitude = "";
  bool _showErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomScreenHeader("add_branch"),
          SizedBox(height: _size.height(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width(21)),
            child: CustomCard(
              width: 385,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _size.width(21),
                  vertical: _size.height(60),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      _size,
                      "branch_name",
                      _branchName,
                    ),
                    _buildTextField(
                      _size,
                      "branch_phone_number",
                      _branchPhoneNumber,
                    ),
                    if (_showErrorMessage) _buildMessage(_size),
                    _buildGetLocationButton(_size, context),
                    SizedBox(height: _size.height(15)),
                    _buildAddBranchButton(_size, context),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessage(Size _size) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: _size.height(20)),
        child: Text(
          Get.find<AppLocalizationController>().getTranslatedValue(
              _latitude.isNotEmpty && _longitude.isNotEmpty
                  ? "all_fields_required"
                  : "need_location"),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.red,
                fontSize: 16,
              ),
        ),
      ),
    );
  }

  Widget _buildAddBranchButton(Size _size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _size.height(5)),
      child: CustomElevatedButton(
        width: 343,
        height: 72,
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("add_new_branch")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
        ),
        onTap: () async {
          if (validate()) {
            EmployeeDataUploaderAPI _employeeDataUploaderAPI =
                EmployeeDataUploaderAPI();
            showDialog(context: context, builder: (_) => PreLoader());
            await _employeeDataUploaderAPI
                .addNewBranch(
              name: _branchName.text,
              phoneNumber: _branchPhoneNumber.text,
              longitude: _longitude,
              latitude: _latitude,
            )
                .catchError((error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              Navigator.pop(context);
            });
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            _showErrorMessage = !validate();
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildGetLocationButton(Size _size, BuildContext context) {
    Color color = ConstData.green_color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(_size.width(10)),
            child: Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("get_location"),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: _latitude.isNotEmpty && _longitude.isNotEmpty
                        ? color
                        : color.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          onTap: () async {
            EmployeeDataUploaderAPI _employeeDataUploaderAPI =
                EmployeeDataUploaderAPI();
            showDialog(context: context, builder: (_) => PreLoader());
            final Position currentPosition = await _employeeDataUploaderAPI
                .getUserCurrentPosition()
                .catchError((error) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
              Navigator.pop(context);
            });
            _latitude = currentPosition.latitude.toString();
            _longitude = currentPosition.longitude.toString();
            setState(() {});
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    Size _size,
    String hintKey,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: _size.height(20)),
      child: CustomTextField(
        hintKey: hintKey,
        controller: controller,
        headerKey: hintKey,
        keyboardType: hintKey.contains("number")
            ? TextInputType.phone
            : TextInputType.name,
        prefixIconName: hintKey.contains("number") ? "phone" : "person",
        prefixIconHeight: _size.height(20),
        prefixIconWidth: _size.width(0),
      ),
    );
  }
}
