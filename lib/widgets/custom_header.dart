import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../const/const_data.dart';

class MyCustomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialClassicHeader(
      color: ConstData.green_color,
    );
  }
}
