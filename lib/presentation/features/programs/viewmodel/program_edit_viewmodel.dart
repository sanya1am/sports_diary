import 'package:flutter/foundation.dart';
import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';
import '../../../../domain/entities/training.dart';


class ProgramEditViewModel extends ChangeNotifier {
  final ProgramRepository repo;
  Program? editing;

  String name = '';
  List<Training> trainings = [];

  int cycleDays = 7;
  List<String?> schedule = [];

  ProgramEditViewModel({required this.repo});

  void startCreate() {
    editing = null;
    name = '';
    trainings = [];
    cycleDays = 7;
    schedule = List<String?>.filled(cycleDays, null);
    notifyListeners();
  }

  void startEdit(Program program) {
    editing = program;
    name = program.name;
    trainings = program.trainings.map((d) => d.copyWith()).toList();
    cycleDays = program.cycleDays;
    schedule = program.schedule.map((id) => trainings.any((t) => t.id == id) ? id : null).toList();
    notifyListeners();
  }

  void addTraining(String dayName) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    trainings = [...trainings, Training(id: id, name: dayName)];
    notifyListeners();
  }

  void removeTraining(String dayId) {
    trainings = trainings.where((d) => d.id != dayId).toList();
    notifyListeners();
  }

  void renameTraining(String dayId, String newName) {
    trainings = trainings.map((d) => d.id == dayId ? d.copyWith(name: newName) : d).toList();
    notifyListeners();
  }

  void setCycleDays(int days) {
    if (days < 1) return;
    cycleDays = days;
    if (schedule.length != days) {
      if (schedule.length > days) schedule = schedule.sublist(0, days);
      else schedule = [...schedule, ...List<String?>.filled(days - schedule.length, null)];
    }
    notifyListeners();
  }

  void assignTrainingToDay(int dayIndex, String? trainingId) {
    if (dayIndex < 0 || dayIndex >= cycleDays) return;
    schedule[dayIndex] = trainingId;
    notifyListeners();
  }

  Future<void> save() async {
    if (schedule.isEmpty || schedule[0] == null) {
      throw Exception('В первый день цикла должна быть назначена тренировка');
    }

    if (editing == null) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final program = Program(
        id: id,
        name: name.trim(),
        trainings: trainings,
        createdAt: DateTime.now(),
        cycleDays: cycleDays,
        schedule: List<String?>.from(schedule),
      );
      await repo.save(program);
      editing = program;
      notifyListeners();
      return;
    }

    final existing = await repo.getById(editing!.id);

    final List<Training> mergedTrainings = [];

    for (final vmT in trainings) {
      Training? storedT;
      if (existing != null) {
        try {
          storedT = existing.trainings.firstWhere((t) => t.id == vmT.id);
        } catch (_) {
          storedT = null;
        }
      }

      if (storedT == null) {
        mergedTrainings.add(vmT);
      } else {
        final exercisesToUse = (vmT.exercises.isNotEmpty) ? vmT.exercises : storedT.exercises;
        mergedTrainings.add(vmT.copyWith(exercises: exercisesToUse));
      }
    }

    final updated = editing!.copyWith(
      name: name.trim(),
      trainings: mergedTrainings,
      cycleDays: cycleDays,
      schedule: List<String?>.from(schedule),
      updatedAt: DateTime.now(),
    );

    await repo.save(updated);
    editing = updated;
    notifyListeners();
  }

  Future<void> refreshFromRepo() async {
    if (editing == null) return;
    try {
      final stored = await repo.getById(editing!.id);
      if (stored == null) return;
      name = stored.name;
      trainings = stored.trainings.map((t) => t.copyWith()).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('ProgramEditViewModel.refreshFromRepo error: $e');
    }
  }

  Future<void> delete() async {
    if (editing == null) return;
    await repo.delete(editing!.id);
    editing = null;
    name = '';
    trainings = [];
    notifyListeners();
  }
}