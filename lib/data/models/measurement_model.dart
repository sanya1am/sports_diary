import 'package:sports_diary/domain/entities/measurement.dart';

class MeasurementModel {
  final String id;
  final String name;
  final double value;
  final int createdAtMs;
  final int? updatedAtMs;

  MeasurementModel({
    required this.id,
    required this.name,
    required this.value,
    required this.createdAtMs,
    this.updatedAtMs,
  });

  factory MeasurementModel.fromDomain(Measurement m) => MeasurementModel(
    id: m.id,
    name: m.name,
    value: m.value,
    createdAtMs: m.createdAt.millisecondsSinceEpoch,
    updatedAtMs: m.updatedAt?.millisecondsSinceEpoch,
  );

  Measurement toDomain() => Measurement(
    id: id,
    name: name,
    value: value,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    updatedAt: updatedAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(updatedAtMs!),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'value': value,
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
  };

  factory MeasurementModel.fromMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final name = (m['name'] ?? '').toString();
    final valueRaw = m['value'];
    final double value = valueRaw is num ? valueRaw.toDouble() : double.tryParse(valueRaw?.toString() ?? '') ?? 0.0;
    final createdAtMs = m['createdAtMs'] is int ? m['createdAtMs'] as int : int.tryParse(m['createdAtMs']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch;
    final updatedAtMs = m['updatedAtMs'] is int ? m['updatedAtMs'] as int : (int.tryParse(m['updatedAtMs']?.toString() ?? ''));

    return MeasurementModel(
      id: id,
      name: name,
      value: value,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
    );
  }
}