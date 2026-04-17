class DashboardStats {
  final int totalGear;
  final int criticalCount;
  final int lowStockCount;
  final int inStockCount;

  DashboardStats({
    required this.totalGear,
    required this.criticalCount,
    required this.lowStockCount,
    required this.inStockCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalGear: json['totalGear'] as int,
      criticalCount: json['criticalCount'] as int,
      lowStockCount: json['lowStockCount'] as int,
      inStockCount: json['inStockCount'] as int,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalGear: 0,
      criticalCount: 0,
      lowStockCount: 0,
      inStockCount: 0,
    );
  }
}
