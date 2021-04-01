import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class PickerDetail extends StatelessWidget {
  final ScreenUtil screenUtil;
  final Color textColor;
  final FixedExtentScrollController controller;
  final int expand;
  final double curveAmount;
  final List<Center> display;
  final Function method;

  PickerDetail(
      {@required this.screenUtil,
      this.textColor,
      @required this.controller,
      @required this.expand,
      @required this.curveAmount,
      @required this.display,
      @required this.method});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: expand,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: textColor,
              fontSize: screenUtil.setWidth(25.0) > screenUtil.setHeight(22.0)
                  ? screenUtil.setHeight(22.0)
                  : screenUtil.setWidth(25.0),
            ),
          ),
        ),
        child: CupertinoPicker(
          scrollController: controller,
          useMagnifier: true,
          magnification: 1.1,
          offAxisFraction: curveAmount,
          squeeze: 1.2,
          looping: true,
          itemExtent: screenUtil.setHeight(35.0),
          children: display,
          onSelectedItemChanged: (index) {
            method(index);
          },
        ),
      ),
    );
  }
}
