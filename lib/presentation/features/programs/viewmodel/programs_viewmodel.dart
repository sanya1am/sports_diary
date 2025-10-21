import 'package:flutter_riverpod/legacy.dart';
import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/repositories/programs_repository.dart';

class ProgramsState {
  final bool isLoading;
  final List<Program> programs;
  ProgramsState({required this.isLoading, required this.programs});
  ProgramsState.initial() : isLoading = true, programs = [];
}

class ProgramsViewModel extends StateNotifier<ProgramsState> {
  final ProgramsRepository _repo;

  ProgramsViewModel(this._repo) : super(ProgramsState.initial()) {
    _load();
  }

  Future<void> _load() async {
    state = ProgramsState(isLoading: true, programs: []);
    final list = await _repo.getAllPrograms();
    state = ProgramsState(isLoading: false, programs: list);
  }

  void createNewProgram() {
    _repo.createProgram(Program(id: 'new', name: 'Новая программа', daysCount: 1));
    _load();
  }

  void openProgram(String id) {

  }
}