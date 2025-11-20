import 'package:sports_diary/domain/entities/exercise.dart';

class Training {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Training({
    required this.id,
    required this.name,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  Training copyWith({String? name, List<Exercise>? exercises}) =>
      Training(id: id, name: name ?? this.name, exercises: exercises ?? this.exercises);
}