enum StockStatus { inStock, lowStock, critical }

class GearItem {
  final int id;
  final String name;
  final int divisionId;
  final String divisionName;
  final int quantity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GearItem({
    required this.id,
    required this.name,
    required this.divisionId,
    required this.divisionName,
    required this.quantity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  StockStatus get status {
    if (quantity <= 5) return StockStatus.critical;
    if (quantity <= 15) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  factory GearItem.fromJson(Map<String, dynamic> json) {
    return GearItem(
      id: json['id'] as int,
      name: json['name'] as String,
      divisionId: json['divisionId'] as int,
      divisionName: json['divisionName'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
