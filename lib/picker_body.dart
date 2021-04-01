import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cupertinopicker/picker_style.dart';
import 'package:flutter_cupertinopicker/transition_shield.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter/material.dart';

Future<Widget> showCustomDatePicker(
    {@required BuildContext context,
    double adaptWidth = 414.0,
    double adaptHeight = 736.0,
    Color cancelColor,
    Color confirmColor,
    Color textColor,
    Color titleBgColor,
    Color backgroundColor,
    DateTime initialDate,
    @required void Function(String) onConfirm}) async {
  if (context == null) {
    print("context must not be null!!!");
  }
  assert(context != null);

  int birthYear;
  int birthMonth;
  int birthDate;
  if (initialDate == null) {
    birthYear = DateTime.now().year;
    birthMonth = DateTime.now().month;
    birthDate = DateTime.now().day;
  } else {
    birthYear = initialDate.year;
    birthMonth = initialDate.month;
    birthDate = initialDate.day;
  }

  final mediaQuery = MediaQuery.of(context);
  ScreenUtil.init(context, width: adaptWidth, height: adaptHeight);
  final ScreenUtil screenUtil = ScreenUtil();
  final theme = Theme.of(context);

  int _birthYear = birthYear;
  int _birthMonth = birthMonth;
  int _birthDate = birthDate;
  int thisYear = DateTime.now().year.toInt();
  List<int> yearNum = List<int>();
  List<int> leapYear = List<int>();
  List<int> monthNum = List<int>();
  List<int> lunarMonth = List<int>();
  List<int> dateNum = List<int>();

  ///starts from 1900/01/01
  for (var i = 1900; i <= thisYear; i++) {
    yearNum.add(i);
  }

  for (var i = 1900; i <= thisYear; i++) {
    if (i % 4 == 0 && i % 100 != 0) {
      leapYear.add(i);
    } else if (i % 400 == 0) {
      leapYear.add(i);
    } else {
      continue;
    }
  }

  for (var i = 1; i <= 12; i++) {
    monthNum.add(i);
  }
  for (var i = 2; i <= 12; i = i + 2) {
    if (i == 8) {
      i = i + 1;
      lunarMonth.add(i);
      continue;
    }
    lunarMonth.add(i);
  }

  for (var i = 1; i <= 31; i++) {
    dateNum.add(i);
  }

  List<Center> year = yearNum
      .map((each) => Center(child: Text("${each.toString()}年")))
      .toList();
  List<Center> month = monthNum.map((each) {
    if (each < 10) {
      return Center(child: Text("0${each.toString()}月"));
    }
    return Center(child: Text("${each.toString()}月"));
  }).toList();
  List<Center> date = dateNum.map((each) {
    if (each < 10) {
      return Center(child: Text("0${each.toString()}日"));
    }
    return Center(child: Text("${each.toString()}日"));
  }).toList();

  int indexYear = yearNum.indexOf(birthYear);
  int indexMonth = monthNum.indexOf(birthMonth);
  int indexDate = dateNum.indexOf(birthDate);

  FixedExtentScrollController scrollControllerYear =
      FixedExtentScrollController(initialItem: indexYear);
  FixedExtentScrollController scrollControllerMonth =
      FixedExtentScrollController(initialItem: indexMonth);
  FixedExtentScrollController scrollControllerDate =
      FixedExtentScrollController(initialItem: indexDate);


  return showModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (context) {
        return MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: 1.0),
          child: Container(
            color: backgroundColor ?? Color.fromRGBO(245, 245, 245, 1),
            height: screenUtil.setHeight(300.0),
            child: Column(children: [
              Container(
                color: titleBgColor ?? Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                            padding: EdgeInsets.all(
                              screenUtil.setHeight(12.0),
                            ),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                  color: cancelColor ??
                                      Color.fromRGBO(204, 204, 204, 1),
                                  fontSize: screenUtil.setHeight(15.5)),
                            ))),
                    GestureDetector(
                        onTap: () {
                          String monthString;
                          String dateString;
                          if (_birthMonth < 10) {
                            monthString = "0${_birthMonth.toString()}";
                          } else {
                            monthString = _birthMonth.toString();
                          }
                          if (_birthDate < 10) {
                            dateString = "0${_birthDate.toString()}";
                          } else {
                            dateString = _birthDate.toString();
                          }
                          if (onConfirm != null) {
                            onConfirm(
                                "${_birthYear.toString()}年$monthString月$dateString日");
                          }

                          Navigator.of(context).pop();
                        },
                        child: Padding(
                            padding: EdgeInsets.all(
                              screenUtil.setHeight(12.0),
                            ),
                            child: Text(
                              "確定",
                              style: TextStyle(
                                  color: confirmColor ?? theme.primaryColor,
                                  fontSize: screenUtil.setHeight(15.5)),
                            ))),
                    SizedBox(
                      width: screenUtil.setWidth(5.0),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Stack(children: [
                  Row(children: [
                    SizedBox(
                      width: screenUtil.setHeight(30.0),
                    ),
                    PickerStyle(
                        screenUtil: screenUtil,
                        textColor: textColor,
                        controller: scrollControllerYear,
                        expand: 2,
                        curveAmount: -0.3,
                        display: year,
                        method: (index) {
                          _birthYear = yearNum[index];
                          _checkLeap(
                              screenUtil,
                              leapYear,
                              _birthDate,
                              scrollControllerDate,
                              yearNum[index],
                              _birthMonth);
                          _checkExceed(
                              screenUtil,
                              yearNum[index],
                              _birthMonth,
                              _birthDate,
                              scrollControllerYear,
                              scrollControllerMonth,
                              scrollControllerDate,
                              yearNum,
                              monthNum,
                              dateNum);
                        }),
                    PickerStyle(
                        screenUtil: screenUtil,
                        textColor: textColor,
                        controller: scrollControllerMonth,
                        expand: 1,
                        curveAmount: 0.0,
                        display: month,
                        method: (index) {
                          _birthMonth = monthNum[index];
                          _checkLeap(screenUtil, leapYear, _birthDate,
                              scrollControllerDate, _birthYear, _birthMonth);
                          _checkLunar(screenUtil, lunarMonth, _birthDate,
                              scrollControllerDate, _birthMonth);
                          _checkExceed(
                              screenUtil,
                              _birthYear,
                              monthNum[index],
                              _birthDate,
                              scrollControllerYear,
                              scrollControllerMonth,
                              scrollControllerDate,
                              yearNum,
                              monthNum,
                              dateNum);
                        }),
                    PickerStyle(
                        screenUtil: screenUtil,
                        textColor: textColor,
                        controller: scrollControllerDate,
                        expand: 2,
                        curveAmount: 0.3,
                        display: date,
                        method: (index) {
                          _checkLeap(screenUtil, leapYear, dateNum[index],
                              scrollControllerDate, _birthYear, _birthMonth);
                          _checkLunar(screenUtil, lunarMonth, dateNum[index],
                              scrollControllerDate, _birthMonth);
                          _checkExceed(
                              screenUtil,
                              _birthYear,
                              _birthMonth,
                              dateNum[index],
                              scrollControllerYear,
                              scrollControllerMonth,
                              scrollControllerDate,
                              yearNum,
                              monthNum,
                              dateNum);
                          _birthDate = dateNum[index];
                        }),
                    SizedBox(width: screenUtil.setHeight(30.0)),
                  ]),
                  TransitionShield(
                      screenUtil: screenUtil,
                      direction1: Alignment.topCenter,
                      direction2: Alignment.bottomCenter,
                      shieldColor: backgroundColor ??
                          Color.fromRGBO(245, 245, 245, 1)),
                  Positioned(
                      bottom: 0.0,
                      child: TransitionShield(
                        screenUtil: screenUtil,
                        direction1: Alignment.bottomCenter,
                        direction2: Alignment.topCenter,
                        shieldColor: backgroundColor ??
                            Color.fromRGBO(245, 245, 245, 1),
                      )),
                ]),
              ),
            ]),
          ),
        );
      });
}

///判斷閏年
void _checkLeap(
  ScreenUtil screenUtil,
  List<int> leapYear,
  int date,
  FixedExtentScrollController scrollControllerDate,
  int birthYear,
  int birthMonth,
) {
  if (!leapYear.contains(birthYear) &&
      birthMonth == 2 &&
      (date == 29 || date == 30 || date == 31)) {
    if (scrollControllerDate.position.userScrollDirection ==
        ScrollDirection.reverse) {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    }
  } else if (leapYear.contains(birthYear) &&
      birthMonth == 2 &&
      (date == 30 || date == 31)) {
    if (scrollControllerDate.position.userScrollDirection ==
        ScrollDirection.reverse) {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    }
  }
}

///判斷大小月
void _checkLunar(ScreenUtil screenUtil, List<int> lunarMonth, int date,
    FixedExtentScrollController scrollControllerDate, int birthMonth) {
  if (lunarMonth.contains(birthMonth) && date == 31) {
    if (scrollControllerDate.position.userScrollDirection ==
        ScrollDirection.reverse) {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(
          scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    }
  }
}

///判斷所選日期是否大於現在
void _checkExceed(
    ScreenUtil screenUtil,
    int birthYear,
    int birthMonth,
    int date,
    FixedExtentScrollController scrollControllerYear,
    FixedExtentScrollController scrollControllerMonth,
    FixedExtentScrollController scrollControllerDate,
    List<int> yearNum,
    List<int> monthNum,
    List<int> dateNum) {
  DateTime now = DateTime.now();
  String month = now.month.toString().length < 2
      ? "0" + now.month.toString()
      : now.month.toString();
  String day = now.day.toString().length < 2
      ? "0" + now.day.toString()
      : now.day.toString();
  String selectMonth = birthMonth.toString().length < 2
      ? "0" + birthMonth.toString()
      : birthMonth.toString();
  String selectDay =
      date.toString().length < 2 ? "0" + date.toString() : date.toString();
  String select = birthYear.toString() + selectMonth + selectDay;
  String max = now.year.toString() + month + day;
  if (int.parse(select) > int.parse(max)) {
    int indexY = yearNum.indexOf(now.year);
    int indexM = monthNum.indexOf(now.month);
    int indexD = dateNum.indexOf(now.day);
    scrollControllerYear.animateToItem(indexY,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    scrollControllerMonth.animateToItem(indexM,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    scrollControllerDate.animateToItem(indexD,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}
