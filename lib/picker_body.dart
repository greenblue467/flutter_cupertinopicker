import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cupertinopicker/picker_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<Widget?> showCustomDatePicker(
    {required BuildContext context,
    double adaptWidth = 414.0,
    double adaptHeight = 736.0,
    double textScale = 1.0,
    bool textWeightBold = false,
    Color? cancelColor,
    Color? confirmColor,
    Color? titleBgColor,
    DateTime? initialDate,
    bool restrict = false,
    bool isDarkMode = false,
    required void Function(String, int, int, int) onConfirm}) async {
  ///restrict is for preventing users from choosing future date, the default is false


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
  ScreenUtil.init(
      BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
      designSize: Size(adaptWidth, adaptHeight));
  final ScreenUtil screenUtil = ScreenUtil();
  final theme = Theme.of(context);

  int _birthYear = birthYear;
  int _birthMonth = birthMonth;
  int _birthDate = birthDate;
  int thisYear = DateTime.now().year.toInt();
  List<int> yearNum = [];
  List<int> leapYear = [];
  List<int> monthNum = [];
  List<int> lunarMonth = [];
  List<int> dateNum = [];

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

  List<Center> year = yearNum.map((each) => Center(child: Text("${each.toString()}年"))).toList();
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

  FixedExtentScrollController scrollControllerYear = FixedExtentScrollController(initialItem: indexYear);
  FixedExtentScrollController scrollControllerMonth = FixedExtentScrollController(initialItem: indexMonth);
  FixedExtentScrollController scrollControllerDate = FixedExtentScrollController(initialItem: indexDate);
  Color _shield = isDarkMode ? Colors.black : Color.fromRGBO(245, 245, 245, 1);
  return showModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (context) {
        Widget child = Container(
          color: isDarkMode ? _shield : Colors.white,
          child: Row(children: [
            SizedBox(
              width: screenUtil.setHeight(30.0),
            ),
            PickerDetail(
                screenUtil: screenUtil,
                textColor: isDarkMode ? Colors.white.withOpacity(0.8) : Color.fromRGBO(101, 101, 101, 1),
                controller: scrollControllerYear,
                expand: 2,
                curveAmount: -0.3,
                display: year,
                method: (index) {
                  _birthYear = yearNum[index];
                  _checkLeap(screenUtil, leapYear, _birthDate, scrollControllerDate, yearNum[index], _birthMonth);
                  if (restrict) {
                    _checkExceed(screenUtil, yearNum[index], _birthMonth, _birthDate, scrollControllerYear,
                        scrollControllerMonth, scrollControllerDate, yearNum, monthNum, dateNum);
                  }
                }),
            PickerDetail(
                screenUtil: screenUtil,
                textColor: isDarkMode ? Colors.white.withOpacity(0.8) : Color.fromRGBO(101, 101, 101, 1),
                controller: scrollControllerMonth,
                expand: 1,
                curveAmount: 0.0,
                display: month,
                method: (index) {
                  _birthMonth = monthNum[index];
                  _checkLeap(screenUtil, leapYear, _birthDate, scrollControllerDate, _birthYear, _birthMonth);
                  _checkLunar(screenUtil, lunarMonth, _birthDate, scrollControllerDate, _birthMonth);
                  if (restrict) {
                    _checkExceed(screenUtil, _birthYear, monthNum[index], _birthDate, scrollControllerYear,
                        scrollControllerMonth, scrollControllerDate, yearNum, monthNum, dateNum);
                  }
                }),
            PickerDetail(
                screenUtil: screenUtil,
                textColor: isDarkMode ? Colors.white.withOpacity(0.8) : Color.fromRGBO(101, 101, 101, 1),
                controller: scrollControllerDate,
                expand: 2,
                curveAmount: 0.3,
                display: date,
                method: (index) {
                  _checkLeap(screenUtil, leapYear, dateNum[index], scrollControllerDate, _birthYear, _birthMonth);
                  _checkLunar(screenUtil, lunarMonth, dateNum[index], scrollControllerDate, _birthMonth);
                  if (restrict) {
                    _checkExceed(screenUtil, _birthYear, _birthMonth, dateNum[index], scrollControllerYear,
                        scrollControllerMonth, scrollControllerDate, yearNum, monthNum, dateNum);
                  }

                  _birthDate = dateNum[index];
                }),
            SizedBox(width: screenUtil.setHeight(30.0)),
          ]),
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: textScale, boldText: textWeightBold),
          child: SizedBox(
            height: screenUtil.setHeight(300.0),
            child: Column(children: [
              Container(
                color: titleBgColor ?? (isDarkMode ? Color.fromRGBO(10, 10, 10, 1) : Colors.white),
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
                                      (isDarkMode ? Colors.white.withOpacity(0.4) : Color.fromRGBO(204, 204, 204, 1)),
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
                            onConfirm("${_birthYear.toString()}年$monthString月$dateString日", _birthYear, _birthMonth,
                                _birthDate);
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
                                  color: confirmColor ?? (isDarkMode ? Colors.white : theme.primaryColor),
                                  fontSize: screenUtil.setHeight(15.5)),
                            ))),
                    SizedBox(
                      width: screenUtil.setWidth(5.0),
                    )
                  ],
                ),
              ),
              Expanded(
                child: isDarkMode
                    ? child
                    : ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            tileMode: TileMode.clamp,
                            colors: [
                              _shield.withOpacity(0.0),
                              _shield.withOpacity(0.2),
                              _shield.withOpacity(0.8),
                              _shield.withOpacity(1.0),
                              _shield.withOpacity(0.8),
                              _shield.withOpacity(0.2),
                              _shield.withOpacity(0.0),
                            ]).createShader(rect),
                        child: child,
                      ),
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
  if (!leapYear.contains(birthYear) && birthMonth == 2 && (date == 29 || date == 30 || date == 31)) {
    if (scrollControllerDate.position.userScrollDirection == ScrollDirection.reverse) {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  } else if (leapYear.contains(birthYear) && birthMonth == 2 && (date == 30 || date == 31)) {
    if (scrollControllerDate.position.userScrollDirection == ScrollDirection.reverse) {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }
}

///判斷大小月
void _checkLunar(ScreenUtil screenUtil, List<int> lunarMonth, int date,
    FixedExtentScrollController scrollControllerDate, int birthMonth) {
  if (lunarMonth.contains(birthMonth) && date == 31) {
    if (scrollControllerDate.position.userScrollDirection == ScrollDirection.reverse) {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels + screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      scrollControllerDate.animateTo(scrollControllerDate.position.pixels - screenUtil.setHeight(35.0),
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
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
  String month = now.month.toString().length < 2 ? "0" + now.month.toString() : now.month.toString();
  String day = now.day.toString().length < 2 ? "0" + now.day.toString() : now.day.toString();
  String selectMonth = birthMonth.toString().length < 2 ? "0" + birthMonth.toString() : birthMonth.toString();
  String selectDay = date.toString().length < 2 ? "0" + date.toString() : date.toString();
  String select = birthYear.toString() + selectMonth + selectDay;
  String max = now.year.toString() + month + day;
  if (int.parse(select) > int.parse(max)) {
    int indexY = yearNum.indexOf(now.year);
    int indexM = monthNum.indexOf(now.month);
    int indexD = dateNum.indexOf(now.day);
    scrollControllerYear.animateToItem(indexY, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    scrollControllerMonth.animateToItem(indexM, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    scrollControllerDate.animateToItem(indexD, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}
