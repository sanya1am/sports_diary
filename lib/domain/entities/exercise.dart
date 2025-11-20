import 'approach.dart';

class Exercise {
  final String id;
  final String name;
  final String? muscleGroup;
  final List<Approach> approaches;
  final bool restBetweenApproaches;

  Exercise({
    required this.id,
    required this.name,
    this.muscleGroup,
    required this.approaches,
    this.restBetweenApproaches = false,
  });

  Exercise copyWith({
    String? name,
    String? muscleGroup,
    List<Approach>? approaches,
    bool? restBetweenApproaches,
  }) =>
      Exercise(
        id: id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        approaches: approaches ?? this.approaches,
        restBetweenApproaches: restBetweenApproaches ?? this.restBetweenApproaches,
      );
}
