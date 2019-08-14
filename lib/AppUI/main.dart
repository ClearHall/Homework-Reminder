import 'package:flutter/material.dart';
import 'package:homework_reminder/HuntyAppCore/globalSupportVariables.dart';
import 'package:homework_reminder/HuntyAppCore/types.dart';
import 'package:homework_reminder/HuntyAppCore/customDialogOptions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var textController = TextEditingController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

class _PeriodsTableState extends State<PeriodsTable>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  var animatedHeightValues = [0.0];

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 100));
    Tween tween = new Tween<double>(begin: 0.0, end: 75.0);
    animation = tween.animate(controller);
    animation.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  okAddPeriodPressed() {
    animatedHeightValues.add(75.0);
    controller.reset();
    controller.forward();
    periods.add(Period(DateTime.now(), periods.length, "TestPeriod"));
    periods[periods.length - 1].name = textController.text;
  }

  @override
  Widget build(BuildContext context) {
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
      rows.add(PeriodCell(isLastValue, animation, pd, this));
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
class PeriodCell extends Container {
  bool isLastValue;
  Animation animation;
  Period pdName;
  _PeriodsTableState parent;

  PeriodCell(bool iLV, Animation anim, Period name, _PeriodsTableState parent) {
    isLastValue = iLV;
    animation = anim;
    pdName = name;
    this.parent = parent;
  }

  okEditPeriodPressed() {
    parent.setState(() {
      pdName.name = textController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: isLastValue ? animation.value : 75,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: InkWell(
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
              child: isLastValue && animation.value != 75
                  ? null
                  : ListTile(
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
                          )
                        ],
                      ),
                      trailing: new Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colors.white70,
                              size: 30,
                            ),
                            alignment: Alignment.topCenter,
                          )
                        ],
                      ),
                    )),
        ));
  }
}
