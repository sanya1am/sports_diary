import 'package:sports_diary/domain/entities/approach.dart';


class ApproachModel {
  final int count;
  final int reps;
  final double? weight;

  ApproachModel({required this.count, required this.reps, this.weight});

  factory ApproachModel.fromDomain(Approach a) =>
      ApproachModel(count: a.count, reps: a.reps, weight: a.weight);

  Approach toDomain() => Approach(count: count, reps: reps, weight: weight);

  Map<String, dynamic> toMap() => {
    'count': count,
    'reps': reps,
    'weight': weight,
  };

  factory ApproachModel.fromMap(Map<String, dynamic> m) {
    final count = m['count'] is int ? m['count'] as int : int.tryParse(m['count']?.toString() ?? '') ?? 1;
    final reps = m['reps'] is int ? m['reps'] as int : int.tryParse(m['reps']?.toString() ?? '') ?? 0;
    final weight = m['weight'] is num ? (m['weight'] as num).toDouble() : double.tryParse(m['weight']?.toString() ?? '');
    return ApproachModel(count: count, reps: reps, weight: weight);
  }
}