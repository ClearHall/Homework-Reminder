import 'package:flutter/material.dart';
import 'package:homework_reminder/HuntyAppCore/globalSupportVariables.dart';
import 'package:homework_reminder/HuntyAppCore/types.dart';
import 'package:homework_reminder/HuntyAppCore/customDialogOptions.dart';
import 'package:homework_reminder/HuntyAppCore/notificationCore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import 'dart:convert';

var textController = TextEditingController();
var notificationCore;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    notificationCore = NotificationCore(context);
    notificationCore.init();
    return MaterialApp(
      title: 'Homework Reminder',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: PeriodsTable(title: 'Homework Reminder'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PeriodsTable extends StatefulWidget {
  PeriodsTable({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PeriodsTableState createState() => _PeriodsTableState();
}

class _PeriodsTableState extends State<PeriodsTable>{
  @override
  void initState() {
    super.initState();

    setState(() {
      _getPeriods();
    });
  }

  _isFirstTimeUsingApp(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var isFirstTimeUsingApp = prefs.getBool('isFirstTimeUsingApp');
    if (isFirstTimeUsingApp == null) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        var manufacterName = await _getDeviceManufacturerName();
        prefs.setBool('isFirstTimeUsingApp', false);
        final finalMessage = ConstantManufacturersThatBlockNotifications
            .getMessagePertainingToManufacturer(manufacterName);
        showDialog(
            context: context,
            builder: (BuildContext context) => HuntyDialogForMoreText(
                title: "Notifications for Android",
                description: finalMessage,
                buttonText: "Lets Do It!"));
      }
    }
  }

  _getDeviceManufacturerName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return (androidInfo.manufacturer);
  }

  setReminder(BuildContext context) async {
    notificationCore.displayDailyNotification(
        "Homework Reminder!", "Check and do your homework!", Time(15, 0, 0));
  }

  okAddPeriodPressed() async {
    periods.add(Period(DateTime.now(), "Homework Reminder!"));
    var pd = periods[periods.length - 1];
    pd.name = textController.text;
    _savePeriods();
    setState(() {});
  }

  _savePeriods() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < periods.length; i++) {
      prefs.setString('periodsPrefs${i}name', periods[i].name);
      prefs.setStringList('periodsPrefs${i}assignments', periods[i].assignments);
    }
    prefs.setInt('periodsAmt1', periods.length);
  }

  _getPeriods() async {
    final prefs = await SharedPreferences.getInstance();
    int lim = prefs.getInt('periodsAmt1') ?? 0;
    for (int i = 0; i < lim; i++) {
      Period pd = Period(DateTime.now(), prefs.get('periodsPrefs${i}name'));
      pd.assignments = prefs.getStringList('periodsPrefs${i}assignments');
      periods.add(pd);
    }
  }

  @override
  Widget build(BuildContext context) {
    _isFirstTimeUsingApp(context);
    setReminder(context);
    List<Widget> rows = [
      Divider(
        color: Colors.transparent,
      )
    ];
    if (periods.length == 0) {
      rows.add(Container(
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Card(
              color: Colors.white12,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: Text(
                      'Press the plus on the button to start adding periods!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ))))));
    }
    for (var pd in periods) {
      var isLastValue = periods.indexOf(pd) == periods.length - 1;
      var pdCell = PeriodCell(isLastValue, pd, this);
      rows.add(pdCell);
    }
    var back = Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: ListView(children: rows),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => HuntyDialogWithText(
                    hint: 'Period Name',
                    textController: textController,
                    okPressed: okAddPeriodPressed,
                    title: 'New Period',
                    description:
                        'Enter the name of the period you want to add.',
                    buttonText: "Ok"));
          },
          child: Icon(Icons.add),
        ));
    return back;
  }
}

// ignore: must_be_immutable
class PeriodCell extends StatelessWidget {
  bool isLastValue;
  Period pdName;
  _PeriodsTableState parent;

  PeriodCell(bool iLV, Period name, _PeriodsTableState parent) {
    isLastValue = iLV;
    pdName = name;
    this.parent = parent;
  }

  okEditPeriodPressed() {
    parent.setState(() {
      pdName.name = textController.text;
      parent._savePeriods();
    });
  }

  _onPeriodCellPressed() {
    if (double.parse(pdName.uiInfo['height']) > 75) {
      parent.setState(() {
        pdName.uiInfo['height'] = (75).toString();
      });
    } else {
      parent.setState(() {
        pdName.uiInfo['height'] =
            (20 + 75 + pdName.assignments.length * 10.0).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> homeworkAss = List();
    for (var homework in pdName.assignments) {
      homeworkAss.add(Text(
        homework,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        maxLines: 1,
      ));
    }

    return AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: double.parse(pdName.uiInfo['height']),
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: InkWell(
          onTap: _onPeriodCellPressed,
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => HuntyDialogWithText(
                    hint: 'Period Name',
                    textController: textController,
                    okPressed: okEditPeriodPressed,
                    title: 'Edit Name',
                    description: 'Enter the new name of the period.',
                    buttonText: "Ok"));
          },
          child: Card(
              color: Colors.white12,
              child: ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        child: Text(
                          pdName.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      double.parse(pdName.uiInfo['height']) <= 75
                          ? Container()
                          : Column(children: homeworkAss.length == 0 ? [Text(
                        'No homework assignments!',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      )] : homeworkAss )
                    ]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.add_box,
                        color: Colors.white70,
                        size: 30,
                      ),
                      alignment: Alignment.topCenter,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                HuntyDialogWithText(
                                    hint: 'Assignment Name',
                                    textController: textController,
                                    okPressed: () {
                                      parent.setState(() {
                                        pdName.assignments.add(
                                                textController.text);
                                        parent._savePeriods();
                                      });
                                    },
                                    title: 'Create Assignment',
                                    description:
                                        'Enter the new name of the assignment.',
                                    buttonText: "Ok"));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.white70,
                        size: 30,
                      ),
                      alignment: Alignment.topCenter,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                HuntyDialogForConfirmation(
                                    title: 'Confirm',
                                    description:
                                        'Do you really want to delete this period?',
                                    runIfUserConfirms: () {
                                      this.parent.setState(() {
                                        periods.remove(pdName);
                                        parent._savePeriods();
                                      });
                                    },
                                    btnTextForConfirmation: "I'm Sure",
                                    btnTextForCancel: 'Cancel'));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.white70,
                        size: 30,
                      ),
                      alignment: Alignment.topCenter,
                      onPressed: _onPeriodCellPressed,
                    )
                  ],
                ),
              )),
        ));
  }
}
