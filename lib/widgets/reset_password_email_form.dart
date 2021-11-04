import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/size.dart';
import 'widgets.dart';

class ResetPasswordEmailForm extends StatefulWidget {
  final void Function() _previousScreen;
  final void Function() _loginScreen;
  final void Function() _nextScreen;

  ResetPasswordEmailForm(
    this._nextScreen,
    this._previousScreen,
    this._loginScreen,
  );

  @override
  _ResetPasswordEmailFormState createState() => _ResetPasswordEmailFormState();
}

class _ResetPasswordEmailFormState extends State<ResetPasswordEmailForm> {
  final TextEditingController _emailController = TextEditingController();

  bool _showErrorMessage = false;

  String _errorMessageKey = "email_not_found";

  Future<void> _sentCode() async {
    if (_emailController.text.isNotEmpty) {
      bool valid = await Get.find<LoginController>()
          .sendCodeEmail(_emailController.text)
          .catchError((error) {
        _showErrorMessage = true;
        _errorMessageKey = "$error";
        return false;
      });
      if (valid) {
        FocusScope.of(context).unfocus();
        widget._nextScreen();
      } else {
        setState(() {});
      }
    } else {
      setState(() {
        _showErrorMessage = true;
        _errorMessageKey = "email_not_filled";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: _size.width(21)),
      children: [
        _buildHeader(_size),
        SizedBox(height: _size.height(51)),
        Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("enter_email"),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 14,
                color: Color.fromRGBO(196, 198, 204, 1),
              ),
        ),
        SizedBox(height: _size.height(46)),
        _buildTextField(
          size: _size,
          context: context,
          controller: _emailController,
          hintKey: "email_address",
          prefixIconName: "lock",
          keyboardType: TextInputType.emailAddress,
        ),
        _buildErrorMessage(),
        SizedBox(height: _size.height(51)),
        CustomElevatedButton(
          width: 343,
          height: 72,
          child: Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue("find_your_account")
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          onTap: () {
            setState(() {
              _showErrorMessage = false;
            });
            _sentCode();
          },
        ),
        SizedBox(height: _size.height(30)),
        _buildLoginButton(),
      ],
    );
  }

  Row _buildHeader(Size _size) {
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

  Widget _buildLoginButton() {
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

  Widget _buildErrorMessage() {
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

  Widget _buildTextField({
    required Size size,
    required TextEditingController controller,
    required String hintKey,
    required String prefixIconName,
    required BuildContext context,
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
