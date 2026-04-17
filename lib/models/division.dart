class Division {
  final int id;
  final String name;

  Division({required this.id, required this.name});

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
