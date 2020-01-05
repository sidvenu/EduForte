class Student {
  String studentID, name, phoneNumber, classroomID;
  Student({this.studentID, this.name, this.phoneNumber});
  Student.fromMap(Map<dynamic, dynamic> map)
      : studentID = map["studentID"],
        name = map["name"],
        phoneNumber = map["phoneNumber"],
        classroomID = map["classroomID"];
}
