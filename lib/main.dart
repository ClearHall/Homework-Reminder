import 'package:flutter/material.dart';
import 'globalSupportVariables.dart';
import 'types.dart';

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

  void addPeriod() {
    animatedHeightValues.add(75.0);
    controller.reset();
    setState(() {
      controller.forward();
      periods.add(Period(DateTime.now(), periods.length, "TestPeriod"));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [
      Divider(
        color: Colors.transparent,
      )
    ];
    if (periods.length == 0) {
      rows.add(
        Container(
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Card(
            color: Colors.white12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Text(
                'Press the plus on the button to start adding periods!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    for (var pd in periods) {
      var isLastValue = periods.indexOf(pd) == periods.length - 1;
      rows.add(PeriodCell(isLastValue, animation, pd.name));
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
          onPressed: addPeriod,
          child: Icon(Icons.add),
        ));
    return back;
  }
}

// ignore: must_be_immutable
class PeriodCell extends Container {
  bool isLastValue;
  Animation animation;
  String pdName;

  PeriodCell(bool iLV, Animation anim, String name) {
    isLastValue = iLV;
    animation = anim;
    pdName = name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isLastValue ? animation.value : 75,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                          pdName,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
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
    );
  }
}
