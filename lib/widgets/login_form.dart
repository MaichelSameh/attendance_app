import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../models/size.dart';
import '../screens/home_screen.dart';
import '../widgets/widgets.dart';
import 'no_connection_message.dart';

class LoginForm extends StatefulWidget {
  final void Function() _forgetPasswordPage;
  LoginForm(this._forgetPasswordPage);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  //creating a controller to track the email field changes
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _showErrorMessage = false;
  String? _message;

  Future<void> _registerAuthData(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (ConnectivityResult.none == connectivityResult) {
      showNoInternetMessage(context);
      return;
    } else {
      try {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => PreLoader(),
        );
        Get.find<LoginController>()
            .login(
              _emailController.text,
              _passwordController.text,
            )
            .then((value) => value
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    HomeScreen.route_name, (route) => false)
                : Navigator.of(context).pop())
            .catchError((error) {
          setState(() {
            _showErrorMessage = true;
            _message = error.toString();
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      } catch (e) {
        print("LOGIN_FORM _registerAuthData error: $e");
      }
    }
  }

  void _resetPassword() {
    widget._forgetPasswordPage();
  }

  Future<void> _login(Size _size) async {
    FocusScope.of(context).unfocus();
    //validating that all field are filled
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _showErrorMessage = true;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    //showing a device ID confirmation message in case there is no device ID in the database
    bool showConfirmationText = await Get.find<LoginController>().hasDeviceID;

    if (!showConfirmationText) {
      showDialog(
        context: context,
        builder: (_) => CustomPopUpMessage(
          title: SvgPicture.asset(
            "assets/icons/login_illustrator.svg",
            width: _size.width(182),
            height: _size.height(158),
          ),
          contentKey: "device_id_confirmation",
          warningKey: "device_id_warning",
          actions: [
            CustomElevatedButton(
              width: 150,
              height: 60,
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("logout")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: ConstData.green_color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              color: Colors.transparent,
              onTap: () => Navigator.pop(context),
            ),
            CustomElevatedButton(
              width: 150,
              height: 60,
              child: Text(
                Get.find<AppLocalizationController>()
                    .getTranslatedValue("confirm")
                    .toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              onTap: () {
                _registerAuthData(context);
              },
            ),
          ],
        ),
      );
    } else
      _registerAuthData(context);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _size.width(21)),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildLoginHeader(),
          SizedBox(height: _size.height(28)),
          _buildEmailField(_size),
          SizedBox(height: _size.height(20)),
          _buildPasswordField(_size),
          SizedBox(height: _size.height(12)),
          _buildForgetPasswordButton(),
          _buildErrorMessage(),
          SizedBox(height: _size.height(20)),
          _buildLoginButton(_size)
        ],
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
                    .getTranslatedValue(_message ?? "login_fields_error"),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.red, fontSize: 13),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildPasswordField(Size _size) {
    return _buildTextField(
      controller: _passwordController,
      hintKey: "password",
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

  Widget _buildEmailField(Size _size) {
    return _buildTextField(
      controller: _emailController,
      hintKey: "email",
      prefixIconName: "person",
      size: _size,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Center _buildLoginHeader() {
    return Center(
      child: Text(
        Get.find<AppLocalizationController>()
            .getTranslatedValue("login")
            .toUpperCase(),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  GestureDetector _buildForgetPasswordButton() {
    return GestureDetector(
      onTap: _resetPassword,
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("forget_password"),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: 14, color: Color.fromRGBO(196, 198, 204, 1)),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size _size) {
    return Hero(
      tag: "button",
      child: CustomElevatedButton(
        width: 343,
        height: 72,
        child: Text(
          Get.find<AppLocalizationController>()
              .getTranslatedValue("login")
              .toUpperCase(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        onTap: () {
          setState(() {
            _showErrorMessage = false;
          });
          _login(_size);
        },
      ),
    );
  }

  Widget _buildTextField({
    required Size size,
    required TextEditingController controller,
    required String hintKey,
    required String prefixIconName,
    Widget? suffixIcon,
    bool obscureText = false,
    required TextInputType keyboardType,
  }) {
    return CustomTextField(
      width: null,
      hintKey: hintKey,
      controller: controller,
      obscureText: obscureText,
      prefixIconName: prefixIconName,
      suffixIcon: suffixIcon,
      headerKey: hintKey,
      keyboardType: keyboardType,
    );
  }
}
