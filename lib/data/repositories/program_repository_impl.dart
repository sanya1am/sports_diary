import 'package:hive/hive.dart';
import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/entities/training.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';
import '../models/program_model.dart';


class ProgramRepositoryImpl implements ProgramRepository {
  final Box programsBox;
  final Box settingsBox;

  ProgramRepositoryImpl({required this.programsBox, required this.settingsBox});

  @override
  Future<List<Program>> getAll() async {
    final result = <Program>[];
    for (final value in programsBox.values) {
      if (value is Map) {
        final model = ProgramModel.fromMap(Map<String, dynamic>.from(value));
        result.add(model.toDomain());
      }
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<Program?> getById(String id) async {
    final raw = programsBox.get(id);
    if (raw == null) return null;
    final model = ProgramModel.fromMap(Map<String, dynamic>.from(raw));
    return model.toDomain();
  }

  @override
  Future<void> save(Program program) async {
    final box = Hive.box('programs');
    final model = ProgramModel.fromDomain(program);
    final map = model.toMap();
    await programsBox.put(program.id, map);
  }

  @override
  Future<void> delete(String id) async {
    await programsBox.delete(id);
  }


  @override
  Future<void> addTraining(String programId, Training training) async {
    final prog = await getById(programId);
    if (prog == null) throw Exception('Program not found');
    final updated = prog.copyWith(trainings: [...prog.trainings, training], updatedAt: DateTime.now());
    await save(updated);
  }

  @override
  Future<void> updateTraining(String programId, Training training) async {
    final prog = await getById(programId);
    if (prog == null) throw Exception('Program not found');
    final updatedTrainings = prog.trainings.map((d) => d.id == training.id ? training : d).toList();
    final updated = prog.copyWith(trainings: updatedTrainings, updatedAt: DateTime.now());
    await save(updated);
  }

  @override
  Future<void> deleteTraining(String programId, String trainingId) async {
    final prog = await getById(programId);
    if (prog == null) throw Exception('Program not found');
    final updatedTrainings = prog.trainings.where((d) => d.id != trainingId).toList();
    final updated = prog.copyWith(trainings: updatedTrainings, updatedAt: DateTime.now());
    await save(updated);
  }

}
