import 'package:flutter/foundation.dart';
import 'package:sports_diary/domain/entities/program.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';

class ProgramViewModel extends ChangeNotifier {
  final ProgramRepository repo;

  ProgramViewModel({required this.repo}) : _repo = repo;
  final ProgramRepository _repo;

  List<Program> programs = [];
  Program? selected;

  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    programs = await _repo.getAll();

    if (programs.isNotEmpty && selected == null) selected = programs.first;
    
    if (selected != null && !programs.any((p) => p.id == selected!.id)) selected = programs.isNotEmpty ? programs.first : null;
    loading = false;
    notifyListeners();
  }

  Future<void> selectById(String id) async {
    selected = programs.firstWhere((p) => p.id == id, orElse: () => selected ?? programs.first);
    notifyListeners();
  }

  Future<void> deleteProgram(String id) async {
    await _repo.delete(id);
    await load();
  }

  void _upsertProgramInList(Program p) {
    final idx = programs.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      programs[idx] = p;
    } else {
      programs.add(p);
      programs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<void> refreshSelectedFromRepo() async {
    if (selected == null) return;
    final fresh = await _repo.getById(selected!.id);
    if (fresh == null) {
      // если удалили извне — убрать selected
      programs.removeWhere((p) => p.id == selected!.id);
      selected = programs.isNotEmpty ? programs.first : null;
      notifyListeners();
      return;
    }
    _upsertProgramInList(fresh);

    if (selected!.id == fresh.id) {
      selected = fresh;
    } else {
      selected = fresh;
    }
    notifyListeners();
  }
}