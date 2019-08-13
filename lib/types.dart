class Period{
  DateTime time;
  int periodNumber;
  String name;
  List<HomeworkAssignment> assignments = [];

  Period(DateTime timeInDay, int period, String name){
    time = timeInDay;
    periodNumber = period;
    this.name = name;
  }
}

class HomeworkAssignment{
  String name;

  HomeworkAssignment(String name){
    this.name = name;
  }
}