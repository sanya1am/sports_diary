import 'package:flutter/foundation.dart';
import 'package:sports_diary/domain/entities/exercise.dart';
import 'package:sports_diary/domain/entities/training.dart';
import 'package:sports_diary/domain/repositories/training_repository.dart';

class TrainingViewModel extends ChangeNotifier {
  final TrainingRepository repo;
  final String programId;
  final String trainingId;

  Training? training;
  String trainingName = '';
  List<Exercise> exercises = [];

  bool loading = false;
  String? error;

  TrainingViewModel({
    required this.repo,
    required this.programId,
    required this.trainingId,
  });

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final found = await repo.get(programId, trainingId);
      if (found == null) {
        error = 'Тренировка не найдена';
        training = null;
        trainingName = '';
        exercises = [];
      } else {
        training = found;
        trainingName = training!.name;
        exercises = List<Exercise>.from(training!.exercises);
      }
    } catch (e) {
      error = e.toString();
      training = null;
      trainingName = '';
      exercises = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setTrainingName(String v) {
    trainingName = v;
    notifyListeners();
  }

  void addExercise(Exercise ex) async {
    final prev = List<Exercise>.from(exercises);
    exercises = [...exercises, ex];
    notifyListeners();
    try {
      await repo.addExercise(programId, trainingId, ex);
      await load();
    } catch (e) {
      exercises = prev;
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void updateExercise(String id, Exercise updated) async {
    final prev = List<Exercise>.from(exercises);
    exercises = exercises.map((e) => e.id == id ? updated : e).toList();
    notifyListeners();
    try {
      await repo.updateExercise(programId, trainingId, updated);
      await load();
    } catch (e) {
      exercises = prev;
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void removeExercise(String id) async {
    final prev = List<Exercise>.from(exercises);
    exercises = exercises.where((e) => e.id != id).toList();
    notifyListeners();
    try {
      await repo.deleteExercise(programId, trainingId, id);
      await load();
    } catch (e) {
      exercises = prev;
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> save() async {
    if (training == null) throw Exception('Тренировка не загружена');
    final updatedTraining = training!.copyWith(name: trainingName, exercises: exercises);
    await repo.save(programId, updatedTraining);
    loading = true;
    notifyListeners();

    try {
      await repo.save(programId, updatedTraining);
      training = updatedTraining;
      trainingName = updatedTraining.name;
      exercises = List<Exercise>.from(updatedTraining.exercises);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }

    debugPrint('Saving training $programId/$trainingId exercises=${exercises.length}');
  }
}
