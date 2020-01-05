import 'package:jiffy/jiffy.dart';

class DateHelper {
  static const days = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ];

  static const dateFormat = "yyyy-MM-DD";

  static const dayFormat = "EEEE";

  static String getDay({Jiffy date}) {
    if (date == null) {
      date = Jiffy();
    }
    return date.format(dayFormat).toLowerCase();
  }
}
