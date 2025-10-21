import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sports_diary/data/repositories/programs_repository_impl.dart';
import 'package:sports_diary/domain/repositories/programs_repository.dart';
import 'package:sports_diary/presentation/features/programs/viewmodel/programs_viewmodel.dart';


final programsRepositoryProvider = Provider<ProgramsRepository>((ref) {
  return ProgramsRepositoryImpl();
});


final programsViewModelProvider =
StateNotifierProvider<ProgramsViewModel, ProgramsState>((ref) {
  final repo = ref.watch(programsRepositoryProvider);
  return ProgramsViewModel(repo);
});