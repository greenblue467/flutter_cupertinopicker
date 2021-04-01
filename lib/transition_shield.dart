import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class TransitionShield extends StatelessWidget {
  final ScreenUtil screenUtil;
  final direction1;
  final direction2;

  final Color shieldColor;

  TransitionShield(
      {@required this.screenUtil,
      @required this.direction1,
      @required this.direction2,
      @required this.shieldColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: screenUtil.setHeight(70.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: direction1,
              end: direction2,
              tileMode: TileMode.clamp,
              colors: [
            shieldColor.withOpacity(1.0),
            shieldColor.withOpacity(0.8),
            shieldColor.withOpacity(0.0),
          ])),
    );
  }
}
