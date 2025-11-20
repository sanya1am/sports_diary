import '../../domain/entities/training.dart';
import 'exercise_model.dart';


class TrainingModel {
  final String id;
  final String name;
  final List<ExerciseModel> exercises;

  TrainingModel({required this.id, required this.name, required this.exercises});

  factory TrainingModel.fromDomain(Training d) =>
      TrainingModel(
          id: d.id,
          name: d.name,
          exercises: d.exercises.map((e) => ExerciseModel.fromDomain(e)).toList()
      );

  Training toDomain() => Training(
    id: id,
    name: name,
    exercises: exercises.map((e) => e.toDomain()).toList(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };

  factory TrainingModel.fromMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? DateTime.now().microsecondsSinceEpoch.toString()).toString();
    final name = (m['name'] ?? '').toString();
    final rawExercises = m['exercises'];
    final List<ExerciseModel> exercises = [];
    if (rawExercises is Iterable) {
      for (final e in rawExercises) {
        try {
          if (e is Map) {
            exercises.add(ExerciseModel.fromMap(Map<String, dynamic>.from(e)));
          }
        } catch (_) {}
      }
    }
    return TrainingModel(id: id, name: name, exercises: exercises);
  }
}
