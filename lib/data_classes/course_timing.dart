class CourseTiming {
  String courseCode, startsAt, endsAt;

  CourseTiming({this.courseCode, this.startsAt, this.endsAt});
  CourseTiming.fromMap(Map<dynamic, dynamic> map)
      : courseCode = map["courseCode"],
        startsAt = map["startsAt"],
        endsAt = map["endsAt"];

  static List<CourseTiming> fromDynamicList(List<dynamic> list) {
    return list.map((element) => CourseTiming.fromMap(element)).toList();
  }
}
