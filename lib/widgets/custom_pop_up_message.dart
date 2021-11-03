import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/localization_controller.dart';
import '../models/size.dart';

class CustomPopUpMessage extends StatelessWidget {
  late final Widget? _title;
  late final String? _contentKey;
  late final String? _warningKey;
  late final List<Widget> _actions;
  late final double _contentAndTitleDistance;
  late final Widget _body;
  late final Widget _header;
  CustomPopUpMessage({
    Widget? title,
    String? contentKey,
    String? warningKey,
    List<Widget> actions = const [],
    double contentAndTitleDistance = 44,
    Widget body = const SizedBox(),
    Widget header = const SizedBox(),
  }) {
    this._actions = actions;
    this._contentKey = contentKey;
    this._title = title;
    this._warningKey = warningKey;
    this._contentAndTitleDistance = contentAndTitleDistance;
    this._body = body;
    this._header = header;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: _size.width(398),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: _size.width(29),
            vertical: _size.height(49),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              _size.width(56),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(255, 255, 255, 0.17),
                offset: Offset(0, 11),
                blurRadius: 13,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header,
              Padding(
                padding: EdgeInsets.only(
                    bottom: _size.height(_contentAndTitleDistance)),
                child: _title ?? Container(),
              ),
              _body,
              if (_contentKey != null)
                Text(
                  Get.find<AppLocalizationController>()
                      .getTranslatedValue(_contentKey ?? ""),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 15,
                        color: Color.fromRGBO(168, 167, 167, 1),
                      ),
                ),
              if (_warningKey != null)
                Text(
                  "\n\n" +
                      Get.find<AppLocalizationController>()
                          .getTranslatedValue(_warningKey ?? ""),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 15,
                        color: Color.fromRGBO(236, 30, 84, 1),
                        fontWeight: FontWeight.normal,
                      ),
                ),
              Padding(
                padding: EdgeInsets.only(
                    top: _contentKey != null || _warningKey != null
                        ? _size.height(32)
                        : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
