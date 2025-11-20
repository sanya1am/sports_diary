import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:sports_diary/data/repositories/program_repository_impl.dart';
import 'package:sports_diary/data/repositories/training_repository_impl.dart';
import 'package:sports_diary/domain/entities/exercise.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';
import 'package:sports_diary/domain/repositories/training_repository.dart';
import 'package:sports_diary/presentation/features/programs/viewmodel/exercise_add_viewmodel.dart';
import 'package:sports_diary/presentation/features/programs/viewmodel/program_viewmodel.dart';
import 'package:sports_diary/presentation/features/programs/viewmodel/training_viewmodel.dart';
import '../../domain/entities/program.dart';
import '../../presentation/features/programs/viewmodel/program_edit_viewmodel.dart';


final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  final programsBox = Hive.box('programs');
  final settingsBox = Hive.box('settings');
  return ProgramRepositoryImpl(programsBox: programsBox, settingsBox: settingsBox);
});


final programViewModelProvider = ChangeNotifierProvider<ProgramViewModel>((ref) {
  final repo = ref.read(programRepositoryProvider);
  final vm = ProgramViewModel(repo: repo);
  vm.load();
  ref.onDispose(() => vm.dispose());
  return vm;
});


final programEditViewModelProvider =
ChangeNotifierProvider.family<ProgramEditViewModel, Program?>((ref, program) {
  final repo = ref.read(programRepositoryProvider);
  final vm = ProgramEditViewModel(repo: repo);
  if (program == null) vm.startCreate();
  else vm.startEdit(program);
  ref.onDispose(() => vm.dispose());
  return vm;
});


final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final progRepo = ref.read(programRepositoryProvider);
  return TrainingRepositoryImpl(progRepo);
});


final trainingViewModelProvider =
ChangeNotifierProvider.family.autoDispose<TrainingViewModel, String>(
      (ref, key) {
    final parts = key.split('|');
    final programId = parts[0];
    final trainingId = parts[1];
    final repo = ref.read(trainingRepositoryProvider);
    final vm = TrainingViewModel(repo: repo, programId: programId, trainingId: trainingId);
    vm.load();
    ref.onDispose(() => vm.dispose());
    return vm;
  },
);


final exerciseAddViewModelProvider =
ChangeNotifierProvider.autoDispose.family<ExerciseAddViewModel, Exercise?>(
      (ref, exercise) {
    final vm = ExerciseAddViewModel();
    vm.init(exercise: exercise);
    ref.onDispose(() => vm.dispose());
    return vm;
  },
);

