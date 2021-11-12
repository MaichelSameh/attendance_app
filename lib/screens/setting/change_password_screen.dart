import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../const/const_data.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/login_controller.dart';
import '../../models/size.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_screen_header.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String route_name = "change_password_screen";

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmNewPassword = true;
  bool _showMessage = false;
  bool _messageError = false;

  String _message = "";

  bool validate() {
    return _confirmNewPasswordController.text == _newPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomScreenHeader("change_password"),
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
                      "enter_old_password",
                      _hideOldPassword,
                      _oldPasswordController,
                    ),
                    _buildTextField(
                      _size,
                      "enter_new_password",
                      _hideNewPassword,
                      _newPasswordController,
                    ),
                    _buildTextField(
                      _size,
                      "confirm_new_password",
                      _hideConfirmNewPassword,
                      _confirmNewPasswordController,
                    ),
                    _buildMessage(_size),
                    _buildChangePasswordButton(_size, context),
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
    return _showMessage
        ? Align(
            alignment: Get.find<AppLocalizationController>().isRTLanguage
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: _size.height(20)),
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(_message),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: _messageError ? Colors.red : ConstData.green_color,
                      fontSize: 16,
                    ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildChangePasswordButton(Size _size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _size.height(5)),
      child: CustomElevatedButton(
        width: 343,
        height: 72,
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("change_password")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();
          setState(() {
            _showMessage = false;
          });
          if (validate()) {
            bool changed = await Get.find<LoginController>()
                .changePassword(
                    _oldPasswordController.text, _newPasswordController.text)
                .catchError((error) {
              setState(() {
                _showMessage = true;
                _messageError = true;
                _message = "$error";
              });
            });
            if (changed) {
              setState(() {
                _showMessage = true;
                _messageError = false;
                _message = "password_changed";
              });
            } else {
              _showMessage = true;
              _message = "incorrect_old_password";
              _messageError = true;
            }
          } else {
            setState(() {
              _showMessage = true;
              _messageError = true;
              _message = "passwords_not_matches";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    Size _size,
    String hintKey,
    bool obscureText,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: _size.height(20)),
      child: CustomTextField(
        hintKey: hintKey,
        controller: controller,
        headerKey: hintKey,
        keyboardType: TextInputType.visiblePassword,
        obscureText: obscureText,
        prefixIconName: "lock",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              switch (hintKey) {
                case "enter_old_password":
                  _hideOldPassword = !_hideOldPassword;
                  break;
                case "enter_new_password":
                  _hideNewPassword = !_hideNewPassword;

                  break;
                default:
                  _hideConfirmNewPassword = !_hideConfirmNewPassword;
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(_size.width(10)),
            color: Colors.transparent,
            child: SvgPicture.asset(
              obscureText ? "assets/icons/hide.svg" : "assets/icons/show.svg",
              color: Color.fromRGBO(196, 198, 204, 1),
              width: _size.width(30),
              height: _size.height(25),
            ),
          ),
        ),
      ),
    );
  }
}
