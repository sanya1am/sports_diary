class Measurement {
  final String id;
  final String name;
  final double value;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Measurement({
    required this.id,
    required this.name,
    required this.value,
    required this.createdAt,
    this.updatedAt,
  });

  Measurement copyWith({String? name, double? value, DateTime? updatedAt}) {
    return Measurement(
      id: id,
      name: name ?? this.name,
      value: value ?? this.value,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
