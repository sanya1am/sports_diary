import 'package:sports_diary/domain/entities/exercise.dart';
import 'package:sports_diary/domain/entities/training.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';
import 'package:sports_diary/domain/repositories/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final ProgramRepository _progRepo;
  TrainingRepositoryImpl(this._progRepo);

  @override
  Future<Training?> get(String programId, String trainingId) async {
    final p = await _progRepo.getById(programId);
    if (p == null) {
      return null;
    }
    for (final d in p.trainings) {
      if (d.id == trainingId) {
        return d;
      }
    }
    return null;
  }

  @override
  Future<void> save(String programId, Training training) => _progRepo.updateTraining(programId, training);

  @override
  Future<void> delete(String programId, String trainingId) => _progRepo.deleteTraining(programId, trainingId);


  @override
  Future<void> addExercise(String programId, String trainingId, Exercise exercise) async {
    final prog = await _progRepo.getById(programId);
    if (prog == null) throw Exception('Программа не найдена: $programId');

    final updatedTrainings = prog.trainings.map((t) {
      if (t.id != trainingId) return t;
      final newExercises = [...t.exercises, exercise];
      return t.copyWith(exercises: newExercises);
    }).toList();

    final updatedProgram = prog.copyWith(trainings: updatedTrainings, updatedAt: DateTime.now());
    await _progRepo.save(updatedProgram);
  }

  @override
  Future<void> updateExercise(String programId, String trainingId, Exercise exercise) async {
    final prog = await _progRepo.getById(programId);
    if (prog == null) throw Exception('Программа не найдена: $programId');

    final updatedTrainings = prog.trainings.map((t) {
      if (t.id != trainingId) return t;
      final newExercises = t.exercises.map((e) => e.id == exercise.id ? exercise : e).toList();
      return t.copyWith(exercises: newExercises);
    }).toList();

    final updatedProgram = prog.copyWith(trainings: updatedTrainings, updatedAt: DateTime.now());
    await _progRepo.save(updatedProgram);
  }

  @override
  Future<void> deleteExercise(String programId, String trainingId, String exerciseId) async {
    final prog = await _progRepo.getById(programId);
    if (prog == null) throw Exception('Программа не найдена: $programId');

    final updatedTrainings = prog.trainings.map((t) {
      if (t.id != trainingId) return t;
      final newExercises = t.exercises.where((e) => e.id != exerciseId).toList();
      return t.copyWith(exercises: newExercises);
    }).toList();

    final updatedProgram = prog.copyWith(trainings: updatedTrainings, updatedAt: DateTime.now());
    await _progRepo.save(updatedProgram);
  }
}