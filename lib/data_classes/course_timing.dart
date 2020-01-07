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

  Map<String, String> toMap() {
    return {
      "courseCode": courseCode,
      "startsAt": startsAt,
      "endsAt": endsAt,
    };
  }

  static List<Map<String, String>> toListMap(List<CourseTiming> list) {
    return list.map((element) => element.toMap()).toList();
  }

  bool operator ==(dynamic other) {
    return (other.courseCode == courseCode &&
        other.startsAt == startsAt &&
        other.endsAt == endsAt);
  }
}
