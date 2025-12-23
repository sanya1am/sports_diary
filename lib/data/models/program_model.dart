import 'package:sports_diary/data/models/training_model.dart';
import '../../domain/entities/program.dart';


class ProgramModel {
  final String id;
  final String name;
  final List<TrainingModel> trainings;
  final int createdAtMs;
  final int? updatedAtMs;

  final int cycleDays;
  final List<String?> schedule;

  ProgramModel({
    required this.id,
    required this.name,
    required this.trainings,
    required this.createdAtMs,
    this.updatedAtMs,

    this.cycleDays = 7,
    List<String?>? schedule,
  }) : schedule = schedule ?? List<String?>.filled(cycleDays, null, growable: true);


  factory ProgramModel.fromDomain(Program p) => ProgramModel(
    id: p.id,
    name: p.name,
    trainings: p.trainings.map((d) => TrainingModel.fromDomain(d)).toList(),
    createdAtMs: p.createdAt.millisecondsSinceEpoch,
    updatedAtMs: p.updatedAt?.millisecondsSinceEpoch,
    cycleDays: p.cycleDays,
    schedule: p.schedule,
  );

  Program toDomain() => Program(
    id: id,
    name: name,
    trainings: trainings.map((d) => d.toDomain()).toList(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    updatedAt: updatedAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(updatedAtMs!),
    cycleDays: cycleDays,
    schedule: List<String?>.from(schedule),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'trainings': trainings.map((d) => d.toMap()).toList(),
    'createdAtMs': createdAtMs,
    'updatedAtMs': updatedAtMs,
    'cycleDays': cycleDays,
    'schedule': schedule.map((s) => s).toList(),
  };


  factory ProgramModel.fromMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final name = (m['name'] ?? '').toString();
    final rawTrainings = m['trainings'];
    final List<TrainingModel> trainings = <TrainingModel>[];

    if (rawTrainings is Iterable) {
      for (final e in rawTrainings) {
        try {
          trainings.add(TrainingModel.fromMap(Map<String, dynamic>.from(e)));
        } catch (_) {
        }
      }
    }

    int createdAtMs;
    final createdRaw = m['createdAtMs'];
    if (createdRaw is int) {
      createdAtMs = createdRaw;
    } else if (createdRaw is String) {
      createdAtMs = int.tryParse(createdRaw) ?? DateTime.now().millisecondsSinceEpoch;
    } else {
      createdAtMs = DateTime.now().millisecondsSinceEpoch;
    }

    int? updatedAtMs;
    final updatedRaw = m['updatedAtMs'];
    if (updatedRaw is int) {
      updatedAtMs = updatedRaw;
    } else if (updatedRaw is String) {
      updatedAtMs = int.tryParse(updatedRaw);
    } else {
      updatedAtMs = null;
    }

    final cycleDays = (m['cycleDays'] is int) ? m['cycleDays'] as int : (m['cycleDays'] is String ? int.tryParse(m['cycleDays']) ?? 7 : 7);
    final rawSchedule = m['schedule'];
    List<String?> schedule = List<String?>.filled(cycleDays, null);
    if (rawSchedule is Iterable) {
      final tmp = <String?>[];
      for (final e in rawSchedule) {
        tmp.add(e == null ? null : e.toString());
      }
      // normalize to cycleDays length:
      if (tmp.length >= cycleDays) schedule = tmp.sublist(0, cycleDays);
      else schedule = [...tmp, ...List<String?>.filled(cycleDays - tmp.length, null)];
    } else {
      // if no schedule stored, create sensible default: first N trainings on first N days
      schedule = List<String?>.filled(cycleDays, null);
    }

    return ProgramModel(
      id: id,
      name: name,
      trainings: trainings,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
      cycleDays: cycleDays,
      schedule: schedule,
    );
  }
}