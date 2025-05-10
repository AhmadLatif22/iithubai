class Buyer {
  final int? id;
  final String name;
  final int numberOfCartons;
  final double pricePerCarton;
  final double pricePerContainer;
  final int numberOfContainers;

  Buyer({
    this.id,
    required this.name,
    required this.numberOfCartons,
    required this.pricePerCarton,
    required this.pricePerContainer,
    required this.numberOfContainers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'numberOfCartons': numberOfCartons,
      'pricePerCarton': pricePerCarton,
      'pricePerContainer': pricePerContainer,
      'numberOfContainers': numberOfContainers,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      id: map['id'],
      name: map['name'],
      numberOfCartons: map['numberOfCartons'],
      pricePerCarton: map['pricePerCarton'],
      pricePerContainer: map['pricePerContainer'],
      numberOfContainers: map['numberOfContainers'],
    );
  }
}
