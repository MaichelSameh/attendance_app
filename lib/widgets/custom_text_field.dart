import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart';

class CustomTextField extends StatelessWidget {
  late final double? _width;
  late final double? _height;
  late final double? _prefixIconHeight;
  late final double? _prefixIconWidth;

  late final int _maxLines;
  late final int? _minLines;
  late final int? _maxLength;

  late final TextEditingController? _controller;

  late final BorderRadius? _border;

  late final String _hintKey;
  late final String? _prefixIconName;
  late final String? _headerKey;
  late final bool _expands;
  late final bool _obscureText;

  late final Widget? _suffixIcon;

  late final TextStyle? _hintStyle;

  late final void Function(String)? _onChange;

  late final TextInputType _keyboardType;

  late final EdgeInsets? _padding;

  CustomTextField({
    double? width,
    double? height,
    double? prefixIconHeight,
    double? prefixIconWidth,
    int maxLines = 1,
    int? minLines,
    int? maxLength,
    bool expands = false,
    bool obscureText = false,
    TextEditingController? controller,
    BorderRadius? border,
    required String hintKey,
    String? prefixIconName,
    String? headerKey,
    Widget? suffixIcon,
    TextStyle? hintStyle,
    void Function(String)? onChange,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets? padding,
  }) {
    this._border = border;
    this._controller = controller;
    this._expands = expands;
    this._hintKey = hintKey;
    this._headerKey = headerKey;
    this._hintStyle = hintStyle;
    this._height = height;
    this._maxLength = maxLength;
    this._maxLines = maxLines;
    this._minLines = minLines;
    this._obscureText = obscureText;
    this._prefixIconHeight = prefixIconHeight;
    this._prefixIconName = prefixIconName;
    this._prefixIconWidth = prefixIconWidth;
    this._suffixIcon = suffixIcon;
    this._width = width;
    this._onChange = onChange;
    this._keyboardType = keyboardType;
    this._padding = padding;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_headerKey != null)
          Text(
            Get.find<AppLocalizationController>()
                .getTranslatedValue(_headerKey!),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        if (_headerKey != null) SizedBox(height: _size.height(17)),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              borderRadius: _border ?? BorderRadius.circular(_size.width(14)),
              color: Color.fromRGBO(236, 238, 244, 1),
            ),
            padding: _padding,
            child: Row(
              children: [
                _prefixIconName == null
                    ? Container()
                    : Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: _size.width(15)),
                        child: SvgPicture.asset(
                          "assets/icons/$_prefixIconName.svg",
                          width: _prefixIconWidth,
                          height: _prefixIconHeight,
                        ),
                      ),
                Expanded(
                  child: TextField(
                    maxLength: _maxLength,
                    expands: _expands,
                    maxLines: _expands ? null : _maxLines,
                    minLines: _expands ? null : _minLines,
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.top,
                    textDirection:
                        Get.find<AppLocalizationController>().isRTLanguage
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    decoration: InputDecoration(
                        hintTextDirection:
                            Get.find<AppLocalizationController>().isRTLanguage
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        errorBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: Get.find<AppLocalizationController>()
                            .getTranslatedValue(_hintKey),
                        hintStyle: _hintStyle == null
                            ? Theme.of(context).textTheme.bodyText1!.copyWith(
                                color: Color.fromRGBO(196, 198, 204, 1))
                            : _hintStyle,
                        contentPadding: EdgeInsets.zero),
                    obscureText: _obscureText,
                    onChanged: _onChange,
                    keyboardType: _keyboardType,
                  ),
                ),
                _suffixIcon ?? Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
