import 'package:sports_diary/data/models/approach_model.dart';
import 'package:sports_diary/domain/entities/exercise.dart';


class ExerciseModel {
  final String id;
  final String name;
  final String? muscleGroup;
  final List<ApproachModel> approaches;
  final bool restBetweenApproaches;

  ExerciseModel({
    required this.id,
    required this.name,
    this.muscleGroup,
    required this.approaches,
    this.restBetweenApproaches = false,
  });

  factory ExerciseModel.fromDomain(Exercise e) => ExerciseModel(
    id: e.id,
    name: e.name,
    muscleGroup: e.muscleGroup,
    approaches: e.approaches.map((a) => ApproachModel.fromDomain(a)).toList(),
    restBetweenApproaches: e.restBetweenApproaches,
  );

  Exercise toDomain() => Exercise(
    id: id,
    name: name,
    muscleGroup: muscleGroup,
    approaches: approaches.map((a) => a.toDomain()).toList(),
    restBetweenApproaches: restBetweenApproaches,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'approaches': approaches.map((a) => a.toMap()).toList(),
    'restBetweenApproaches': restBetweenApproaches,
  };

  factory ExerciseModel.fromMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? DateTime.now().microsecondsSinceEpoch.toString()).toString();
    final name = (m['name'] ?? '').toString();
    final raw = m['approaches'];
    final approaches = <ApproachModel>[];
    if (raw is Iterable) {
      for (final el in raw) {
        try {
          if (el is Map) approaches.add(ApproachModel.fromMap(Map<String, dynamic>.from(el)));
        } catch (_) {}
      }
    }
    final rest = m['restBetweenApproaches'] is bool ? m['restBetweenApproaches'] as bool : false;

    return ExerciseModel(
      id: id,
      name: name,
      muscleGroup: m['muscleGroup']?.toString(),
      approaches: approaches,
      restBetweenApproaches: rest,
    );
  }
}