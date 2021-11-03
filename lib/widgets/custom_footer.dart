import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'pre_loader.dart';

class MyCustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (ctx, loadState) {
        if (loadState == LoadStatus.loading) {
          return Center(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: PreLoader(),
            ),
          );
        }
        return Container();
      },
    );
  }
}
