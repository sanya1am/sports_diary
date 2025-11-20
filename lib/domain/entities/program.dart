import 'package:sports_diary/domain/entities/training.dart';

class Program {
  final String id;
  final String name;
  final List<Training> trainings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Program({
    required this.id,
    required this.name,
    required this.trainings,
    required this.createdAt,
    this.updatedAt,
  });

  Program copyWith({String? name, List<Training>? trainings, DateTime? updatedAt}) {
    return Program(
      id: id,
      name: name ?? this.name,
      trainings: trainings ?? this.trainings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
