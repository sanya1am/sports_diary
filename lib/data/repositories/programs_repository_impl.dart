import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/repositories/programs_repository.dart';


class ProgramsRepositoryImpl implements ProgramsRepository {
  final List<Program> _storage = [
    Program(id: 'p1', name: 'Сила — 3 дня', daysCount: 3),
    Program(id: 'p2', name: 'Гипертрофия — 4 дня', daysCount: 4),
  ];

  @override
  Future<List<Program>> getAllPrograms() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_storage);
  }

  @override
  Future<void> createProgram(Program program) async {
    _storage.add(program);
  }
}
