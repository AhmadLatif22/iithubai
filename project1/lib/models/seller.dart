class Seller {
  final int? id;
  final String name;
  final String area;
  final String phone;
  final double rentRate;
  final int numberOfTrolleys;

  Seller({
    this.id,
    required this.name,
    required this.area,
    required this.phone,
    required this.rentRate,
    required this.numberOfTrolleys,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'phone': phone,
      'rentRate': rentRate,
      'numberOfTrolleys': numberOfTrolleys,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      id: map['id'],
      name: map['name'],
      area: map['area'],
      phone: map['phone'],
      rentRate: map['rentRate'],
      numberOfTrolleys: map['numberOfTrolleys'],
    );
  }
}
