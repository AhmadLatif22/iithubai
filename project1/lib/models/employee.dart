class Employee {
  final int? id;
  final String name;
  final String phone;
  final String designation;
  final double salary;
  final int attendance;

  Employee({
    this.id,
    required this.name,
    required this.phone,
    required this.designation,
    required this.salary,
    required this.attendance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'designation': designation,
      'salary': salary,
      'attendance': attendance,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      designation: map['designation'],
      salary: map['salary'],
      attendance: map['attendance'],
    );
  }
}
