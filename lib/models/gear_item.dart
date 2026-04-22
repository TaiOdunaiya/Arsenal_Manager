enum StockStatus { inStock, lowStock, critical }

class GearItem {
  final int id;
  final String name;
  final int divisionId;
  final String divisionName;
  final int quantity;
  final int targetQuantity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GearItem({
    required this.id,
    required this.name,
    required this.divisionId,
    required this.divisionName,
    required this.quantity,
    required this.targetQuantity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get wasJustAdded => updatedAt.difference(createdAt).inSeconds < 2;

  StockStatus get status {
    if (targetQuantity == 0) return StockStatus.inStock;
    final ratio = quantity / targetQuantity;
    if (ratio < 0.40) return StockStatus.critical;
    if (ratio < 0.80) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  factory GearItem.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] as int;
    return GearItem(
      id: json['id'] as int,
      name: json['name'] as String,
      divisionId: json['divisionId'] as int,
      divisionName: json['divisionName'] as String,
      quantity: qty,
      targetQuantity: json['targetQuantity'] as int? ?? qty,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
