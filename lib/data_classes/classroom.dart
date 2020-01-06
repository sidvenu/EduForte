class Classroom {
  String batchYear, departmentCode, oddOrEvenSemester, section, year;
  Set<String> classroomRepresentatives, courses, students;
  Classroom({
    this.batchYear,
    this.departmentCode,
    this.oddOrEvenSemester,
    this.section,
    this.year,
    this.classroomRepresentatives,
    this.courses,
    this.students,
  });
  Classroom.fromMap(Map<dynamic, dynamic> map)
      : batchYear = map["batchYear"],
        departmentCode = map["departmentCode"],
        oddOrEvenSemester = map["oddOrEvenSemester"],
        section = map["section"],
        year = map["year"],
        classroomRepresentatives =
            map["classroomRepresentatives"].cast<String>(),
        courses = map["courses"].cast<String>(),
        students = map["students"].cast<String>();
}
