import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/size.dart';
import 'widgets.dart';

class ResetPasswordNewPasswordForm extends StatefulWidget {
  final void Function() _previousScreen;
  final void Function() _loginScreen;
  ResetPasswordNewPasswordForm(this._previousScreen, this._loginScreen);
  @override
  _ResetPasswordNewPasswordFormState createState() =>
      _ResetPasswordNewPasswordFormState();
}

class _ResetPasswordNewPasswordFormState
    extends State<ResetPasswordNewPasswordForm> {
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _confirmPasswordController = TextEditingController();

  bool loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  bool _showErrorMessage = false;
  String _errorMessageKey = "passwords_not_matching";
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: _size.width(21)),
      children: [
        _buildHeader(context, _size),
        SizedBox(height: _size.height(33)),
        _buildPasswordField(context, _size),
        SizedBox(height: _size.height(20)),
        _buildConfirmPasswordField(context, _size),
        _buildErrorMessage(context),
        SizedBox(height: _size.height(36)),
        _buildSetPasswordButton(_size, context),
        SizedBox(height: _size.height(30)),
        _buildLoginButton(context),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          widget._loginScreen();
        },
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("login")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Color.fromRGBO(145, 145, 145, 1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.only(top: 10),
      duration: Duration(milliseconds: 500),
      child: _showErrorMessage
          ? Container(
              width: double.infinity,
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue(_errorMessageKey),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.red, fontSize: 13),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildPasswordField(BuildContext ctx, Size _size) {
    return _buildTextField(
      controller: _passwordController,
      ctx: ctx,
      hintKey: "enter_new_password",
      prefixIconName: "lock",
      size: _size,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _hidePassword = !_hidePassword;
          });
        },
        child: Container(
          padding: EdgeInsets.all(_size.width(10)),
          child: SvgPicture.asset(
            _hidePassword ? "assets/icons/hide.svg" : "assets/icons/show.svg",
            color: Color.fromRGBO(196, 198, 204, 1),
            width: _size.width(30),
            height: _size.height(25),
          ),
        ),
      ),
      obscureText: _hidePassword,
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Widget _buildConfirmPasswordField(BuildContext ctx, Size _size) {
    return _buildTextField(
      controller: _confirmPasswordController,
      ctx: ctx,
      hintKey: "confirm_new_password",
      prefixIconName: "lock",
      size: _size,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _hideConfirmPassword = !_hideConfirmPassword;
          });
        },
        child: Container(
          padding: EdgeInsets.all(_size.width(10)),
          child: SvgPicture.asset(
            _hideConfirmPassword
                ? "assets/icons/hide.svg"
                : "assets/icons/show.svg",
            color: Color.fromRGBO(196, 198, 204, 1),
            width: _size.width(30),
            height: _size.height(25),
          ),
        ),
      ),
      obscureText: _hideConfirmPassword,
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Row _buildHeader(BuildContext ctx, Size _size) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget._previousScreen,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: _size.width(20),
            child: SvgPicture.asset(
              "assets/icons/back_arrow.svg",
              color: ConstData.green_color,
              width: _size.width(15),
              height: _size.height(12),
              matchTextDirection: true,
            ),
          ),
        ),
        Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("reset_password")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildSetPasswordButton(Size _size, BuildContext ctx) {
    return loading
        ? PreLoader()
        : CustomElevatedButton(
            width: 343,
            height: 72,
            child: Text(
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("set_password")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
            onTap: () async {
              setState(() {
                loading = true;
                _showErrorMessage = false;
              });
              if (_passwordController.text == _confirmPasswordController.text &&
                  (_passwordController.text.contains(RegExp("[a-z]")) &&
                      _passwordController.text.contains(RegExp("[A-Z]")) &&
                      _passwordController.text.contains(RegExp("[0-9]"))) &&
                  _passwordController.text.isNotEmpty) {
                bool valid = await Get.find<LoginController>()
                    .resetPassword(_passwordController.text)
                    .catchError((error) {
                  _showErrorMessage = true;
                  _errorMessageKey = "$error";
                  return false;
                });

                if (valid) {
                  setState(() {
                    loading = false;
                  });
                  FocusScope.of(context).unfocus();
                  widget._loginScreen();
                }
              } else {
                setState(() {
                  loading = false;
                  _showErrorMessage = true;
                  _errorMessageKey = _passwordController.text.isEmpty
                      ? "new_password_not_found"
                      : _passwordController.text !=
                              _confirmPasswordController.text
                          ? "passwords_not_matching"
                          : "weak_password";
                });
              }
            },
          );
  }

  Widget _buildTextField({
    required Size size,
    required BuildContext ctx,
    required TextEditingController controller,
    required String hintKey,
    required String prefixIconName,
    Widget? suffixIcon,
    bool obscureText = false,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Get.find<AppLocalizationController>().getTranslatedValue(hintKey),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: size.height(13)),
        CustomTextField(
          width: null,
          hintKey: hintKey,
          controller: controller,
          obscureText: obscureText,
          prefixIconName: prefixIconName,
          suffixIcon: suffixIcon,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
