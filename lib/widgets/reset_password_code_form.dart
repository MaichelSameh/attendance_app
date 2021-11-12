import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/size.dart';
import 'widgets.dart';

class ResetPasswordCodeForm extends StatefulWidget {
  final void Function() _previousScreen;
  final void Function() _loginScreen;
  final void Function() _nextScreen;

  ResetPasswordCodeForm(
    this._nextScreen,
    this._previousScreen,
    this._loginScreen,
  );

  @override
  _ResetPasswordCodeFormState createState() => _ResetPasswordCodeFormState();
}

class _ResetPasswordCodeFormState extends State<ResetPasswordCodeForm> {
  TextEditingController _codeController = new TextEditingController();

  FocusNode _codeFocusNode = FocusNode();

  bool _showErrorMessage = false;

  String _errorMessageKey = "code_error";

  Widget _buildCodeField(Size _size) {
    List<Widget> fields = [];
    for (int i = 0; i < 6; i++) {
      String code = "";
      try {
        code = _codeController.text[i];
      } catch (e) {
        code = " ";
      }
      fields.add(
        Container(
          width: _size.width(46),
          height: _size.height(64),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromRGBO(236, 238, 244, 1),
            borderRadius: BorderRadius.circular(
              _size.width(15),
            ),
          ),
          child: Text(
            code,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        _codeFocusNode.requestFocus();
      },
      child: Container(
        width: _size.width(322),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
              width: _size.width(322),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: fields,
              ),
            ),
            Opacity(
              opacity: 0,
              child: Container(
                width: _size.width(322),
                height: _size.height(84),
                child: TextField(
                  focusNode: _codeFocusNode,
                  controller: _codeController,
                  maxLength: 6,
                  expands: true,
                  maxLines: null,
                  onChanged: (value) => setState(() {
                    if (value.length == 6) {
                      _getCode();
                    }
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCode() async {
    if (_codeController.text.length == 6) {
      bool valid = await Get.find<LoginController>()
          .validateCode(_codeController.text.trim())
          .catchError((error) {
        _showErrorMessage = true;
        _errorMessageKey = "$error";
        return false;
      });
      if (valid) {
        FocusScope.of(context).unfocus();
        widget._nextScreen();
      } else {
        setState(() {
          _showErrorMessage = true;
          _errorMessageKey = "code_error";
        });
      }
    } else {
      setState(() {
        _showErrorMessage = true;
        _errorMessageKey = "code_not_filled";
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
        SizedBox(height: _size.height(41)),
        Text(
          Get.find<AppLocalizationController>()
                  .getTranslatedValue("check_email") +
              " " +
              Get.find<LoginController>().email +
              " " +
              Get.find<AppLocalizationController>()
                  .getTranslatedValue("email_info"),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 14,
                color: Color.fromRGBO(196, 198, 204, 1),
              ),
        ),
        SizedBox(height: _size.height(44)),
        _buildCodeField(_size),
        _buildErrorMessage(),
        SizedBox(height: _size.height(47)),
        CustomElevatedButton(
          width: 343,
          height: 72,
          child: Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue("reset_password")
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          onTap: () {
            setState(() {
              _showErrorMessage = false;
            });
            _getCode();
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
}
