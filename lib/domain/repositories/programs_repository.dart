import 'package:sports_diary/domain/entities/program.dart';

abstract class ProgramsRepository {
  Future<List<Program>> getAllPrograms();
  Future<void> createProgram(Program program);

}