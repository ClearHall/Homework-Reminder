class Period {
  DateTime time;
  int periodNumber;
  String name;
  List<HomeworkAssignment> assignments = [];

  Period(DateTime timeInDay, int period, String name) {
    time = timeInDay;
    periodNumber = period;
    this.name = name;
  }
}

class HomeworkAssignment {
  String name;

  HomeworkAssignment(String name) {
    this.name = name;
  }
}

class ConstantManufacturersThatBlockNotifications {
  static Map<String, String> manufacturerMessages = Map.fromIterables([
    'HUAWEI',
    'SAMSUNG',
    'XIAOMI',
    'OPPO',
    'ONEPLUS'
  ], [
    'To fix notifications not displaying at all, go to Settings -> Apps -> App launch -> Disable automatically for Homework Reminder -> Auto Launch or Run in Background.',
    'To fix delayed or nonexistent notifications, go to Settings -> Application permissions (for Homework Launcher) and enable it so Homework Reminder can send you notifications.',
    'To fix notifications not working, go to Security -> Permissions -> Autostart -> Swipe to enable Autostart for Homework Reminder.',
    'To fix notifications not working, go to Startup Manager -> Privacy Permissions -> Startup manager -> Swipe to allow Homework Reminder to run in the background and send you notifications.',
    'On OnePlus notifications are a bit tricky, go to Settings -> Battery -> Find Homework Helper and swipe it on.'
  ]);

  static getMessagePertainingToManufacturer(String phoneName) {
    if(manufacturerMessages.containsKey(phoneName)){
      return manufacturerMessages[phoneName];
    }else{
      return 'If you are running an Android version that restricts background processes to save battery life, then please allow Homework Reminder to autostart in your settings so we can successfully send you notifications.\nNote: You got this message because we did not detect a ROM that restricts processes, so you should be fine.';
    }
  }
}
