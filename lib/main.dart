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

class _PeriodsTableState extends State<PeriodsTable> {
  @override
  void initState() {
    super.initState();
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

  setReminder() async {
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
      prefs.setString(
          'periodsPrefs${i}assignments', json.encode(periods[i].assignments));
    }
    prefs.setInt('periodsAmt3', periods.length);
  }

  _convertMapToAssignmentsMap(Map x){
    Map<String, String> tmp = Map();
    for(String key in x.keys){
      tmp[key] = x[key];
    }
    return tmp;
  }

  _getPeriods() async {
    final prefs = await SharedPreferences.getInstance();
    int lim = prefs.getInt('periodsAmt3') ?? 0;
    for (int i = 0; i < lim; i++) {
      Period pd = Period(DateTime.now(), prefs.get('periodsPrefs${i}name'));
      Map assignmentsJson = (json.decode(prefs.getString('periodsPrefs${i}assignments')));
      pd.assignments = _convertMapToAssignmentsMap(assignmentsJson);
      periods.add(pd);
    }
  }

  @override
  Widget build(BuildContext context) {
    _getPeriods();
    _isFirstTimeUsingApp(context);
    setReminder();
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
            (75 + pdName.assignments.length * 55.0).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> homeworkAssTools = List.of({ListTile(
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
//                        double.parse(pdName.uiInfo['height']) <= 75
//                            ? Container()
//                            : Column(
//                                children: homeworkAss.length == 0
//                                    ? [
//                                        Text(
//                                          'No homework assignments!',
//                                          textAlign: TextAlign.start,
//                                          style: TextStyle(
//                                            fontSize: 15,
//                                            color: Colors.white,
//                                          ),
//                                          maxLines: 1,
//                                        )
//                                      ]
//                                    : homeworkAss)
            ]),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                                    pdName.assignments[textController.text] = 'false';
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
                    Icons.settings,
                    color: Colors.white70,
                    size: 30,
                  ),
                  alignment: Alignment.topCenter,
                  onPressed: _onPeriodCellPressed,
                ),
              ],
            )
          ],
        ))});
    for (var homework in pdName.assignments.keys) {
      homeworkAssTools.add(ListTile(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(
          homework,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
      ]),
          trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              pdName.assignments[homework] == 'false' ? Icons.check_box_outline_blank : Icons.check_box,
              color: Colors.white70,
              size: 20,
            ),
            alignment: Alignment.topCenter,
            onPressed: () {
              bool Stored = pdName.assignments[homework] == 'true';
              print(Stored);
              parent.setState(() {
                pdName.assignments[homework] = (!Stored).toString();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white70,
              size: 20,
            ),
            alignment: Alignment.topCenter,
            onPressed: () {
              parent.setState(() {
                pdName.assignments.remove(homework);
                _onPeriodCellPressed();
              });
              },
          ),
//          IconButton(
//            icon: Icon(
//              Icons.date_range,
//              color: Colors.white70,
//              size: 20,
//            ),
//            alignment: Alignment.topCenter,
//            onPressed: () {},
//          ),
        ],
      )));
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
              child: ListView(children: homeworkAssTools,)),
        ));
  }
}
