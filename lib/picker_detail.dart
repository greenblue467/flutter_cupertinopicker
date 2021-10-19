import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PickerDetail extends StatelessWidget {
  final ScreenUtil screenUtil;
  final Color? textColor;
  final FixedExtentScrollController controller;
  final int expand;
  final double curveAmount;
  final List<Center> display;
  final Function method;
  final double? leftRadius;
  final double? rightRadius;

  PickerDetail(
      {required this.screenUtil,
      this.textColor,
      required this.controller,
      required this.expand,
      required this.curveAmount,
      required this.display,
      required this.method,
      this.leftRadius,
      this.rightRadius});

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
          squeeze: 1.3,
          looping: true,
          selectionOverlay: Container(
            margin: EdgeInsets.only(
              left: 0,
              right: 0,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(leftRadius ?? 0.0),
                  right: Radius.circular(rightRadius ?? 0.0),
                ),
                color: CupertinoDynamicColor.resolve(Color.fromARGB(30, 118, 118, 128), context)),
          ),
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
