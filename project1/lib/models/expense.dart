class Expense {
  final int? id;
  final double salaryExpenses;
  final double electricityBill;
  final double cargoExpenses;
  final double laborExpenses;
  final DateTime date;

  Expense({
    this.id,
    required this.salaryExpenses,
    required this.electricityBill,
    required this.cargoExpenses,
    required this.laborExpenses,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salaryExpenses': salaryExpenses,
      'electricityBill': electricityBill,
      'cargoExpenses': cargoExpenses,
      'laborExpenses': laborExpenses,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      salaryExpenses: map['salaryExpenses'],
      electricityBill: map['electricityBill'],
      cargoExpenses: map['cargoExpenses'],
      laborExpenses: map['laborExpenses'],
      date: DateTime.parse(map['date']),
    );
  }
}
