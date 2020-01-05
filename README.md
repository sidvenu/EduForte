# eduforte

## Components

### Edit general time table

- There is a general time table, Monday to Sunday
- It is followed when the CRs create no date-specific time table for the day

### Edit date-specific time table

- **Accessed only by Class Representatives**
- Each date can have a particular time table in cases like the prof is absent, the day is a holiday etc.

## Database Structure

### General Time Table (generalTimeTables)

- classroomID
- day: [monday - sunday]
- courses: Array<{startsAt: "HH:MM", endsAt: "HH:MM", courseCode}>

### Date-specific Time Table (dateSpecificTimeTables)

- classroomID
- date: "YYYY-MM-DD"
- courses: Array<{startsAt: "HH:MM", endsAt: "HH:MM", courseCode}>

### course (courses)

For elective courses and others. Under construction.

### classroomCourse (classroomCourses)

- courseCode: String - like MAIR12
- courseName

### classroom (classroomes)

- classroomID: 8 char length string (ID)
- departmentCode: String
- section: String
- courses: Array<courseCode>
- classroomRepresentatives: Array<studentID>
- students: Array<studentID>
- oddOrEvenSemester: "odd"|"even"
- batchYear
- year

### department (departments)

- departmentCode: EEE, CSE etc. (ID)
- name: String

### student (students)

- studentID: String (ID)
- name: String
- phoneNumber: String

### attendance (attendances)

- studentID: String
- date: "YYYY-MM-DD"
- courses: Array<courseCode>
