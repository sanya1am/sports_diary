import 'package:sports_diary/domain/entities/exercise.dart';
import 'package:sports_diary/domain/entities/training.dart';

abstract class TrainingRepository {
  Future<Training?> get(String programId, String trainingId);
  Future<void> save(String programId, Training training);
  Future<void> delete(String programId, String trainingId);

  Future<void> addExercise(String programId, String trainingId, Exercise exercise);
  Future<void> updateExercise(String programId, String trainingId, Exercise exercise);
  Future<void> deleteExercise(String programId, String trainingId, String exerciseId);
}