import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/entities/training.dart';

abstract class ProgramRepository {
  Future<List<Program>> getAll();
  Future<void> save(Program program);
  Future<void> delete(String id);
  Future<Program?> getById(String id);

  Future<void> addTraining(String programId, Training training);
  Future<void> updateTraining(String programId, Training training);
  Future<void> deleteTraining(String programId, String trainingId);

}