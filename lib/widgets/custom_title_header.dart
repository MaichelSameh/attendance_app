import 'package:flutter/material.dart';

import '../models/size.dart';

class CustomTitleHeader extends StatelessWidget {
  late final double _width;
  late final String _title;
  late final String _subTitle;
  late final Widget _leading;
  late final Color _color;
  CustomTitleHeader({
    required double width,
    required String title,
    String subTitle = "",
    required Widget leading,
    required Color backgroundColor,
  }) {
    this._color = backgroundColor;
    this._leading = leading;
    this._title = title;
    this._width = width;
    this._subTitle = subTitle;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return Center(
      child: Container(
        width: _size.width(_width),
        constraints: BoxConstraints(minHeight: _size.height(91)),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: _size.width(39), vertical: _size.height(19)),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(_size.width(41)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _leading,
            SizedBox(width: _size.width(39)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_title.isNotEmpty)
                  Container(
                    width: _size.width(200),
                    padding: EdgeInsets.only(bottom: _size.height(7)),
                    child: Text(
                      _title.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                if (_subTitle.isNotEmpty)
                  Text(
                    _subTitle,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
