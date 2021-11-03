import 'package:flutter/material.dart';

import '../const/const_data.dart';

class PreLoader extends StatefulWidget {
  @override
  _PreLoaderState createState() => _PreLoaderState();
}

class _PreLoaderState extends State<PreLoader> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: ConstData.green_color,
      ),
    );
  }
}
