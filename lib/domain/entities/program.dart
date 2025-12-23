import 'package:sports_diary/domain/entities/training.dart';

class Program {
  final String id;
  final String name;
  final List<Training> trainings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final int cycleDays;
  final List<String?> schedule;

  Program({
    required this.id,
    required this.name,
    required this.trainings,
    required this.createdAt,
    this.updatedAt,

    this.cycleDays = 7,
    List<String?>? schedule,
  }) : schedule = schedule ?? List<String?>.filled(cycleDays, null, growable: true);

  Program copyWith({
    String? name,
    List<Training>? trainings,
    DateTime? updatedAt,
    int? cycleDays,
    List<String?>? schedule,
  }) {
    final newCycle = cycleDays ?? this.cycleDays;
    final newSchedule = schedule ??
        (this.schedule.length >= newCycle
            ? this.schedule.sublist(0, newCycle)
            : [...this.schedule, ...List<String?>.filled(newCycle - this.schedule.length, null)]);
    return Program(
      id: id,
      name: name ?? this.name,
      trainings: trainings ?? this.trainings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cycleDays: newCycle,
      schedule: newSchedule,
    );
  }
}
