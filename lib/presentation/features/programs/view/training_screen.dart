import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_diary/domain/entities/exercise.dart';
import 'package:sports_diary/presentation/features/programs/view/exercise_add_screen.dart';
import '../../../../core/di/providers.dart';


class TrainingDayScreen extends ConsumerWidget {
  final String programId;
  final String trainingId;

  const TrainingDayScreen({Key? key, required this.programId, required this.trainingId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '${programId}|${trainingId}';
    final vm = ref.watch(trainingViewModelProvider(key));

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.trainingName.isEmpty ? 'Тренировка' : vm.trainingName)
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : (vm.training == null
          ? Center(child: Text(vm.error ?? 'Тренировка не найдена'))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: vm.exercises.isEmpty
                  ? const Center(child: Text('Упражнений нет'))
                  : ListView.separated(
                itemCount: vm.exercises.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final e = vm.exercises[i];
                  // Покажем суммарную информацию: имя + summary подходов
                  final totalApproaches = e.approaches.fold<int>(0, (s, a) => s + a.count);
                  final summary = e.approaches.map((a) {
                    final weightPart = a.weight != null ? ' ${a.weight}kg' : '';
                    return '${a.count}×${a.reps}$weightPart';
                  }).join(', ');
                  return ListTile(
                    title: Text(e.name),
                    subtitle: Text('$summary  •  Всего подходов: $totalApproaches'),
                    onTap: () async {
                      final updated = await Navigator.of(context).push<Exercise?>(
                        MaterialPageRoute(
                          builder: (_) => ExerciseAddScreen(exercise: e),
                        ),
                      );
                      if (updated != null) {
                        vm.updateExercise(e.id, updated);
                      }
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => vm.removeExercise(e.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Начать тренировку'),
                    onPressed: () {
                      // TODO: реализовать логику старта тренировки
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('В разработке')));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  onPressed: () async {
                    final res = await Navigator.of(context).push<Exercise>(
                      MaterialPageRoute(builder: (_) => const ExerciseAddScreen()),
                    );
                    if (res != null) {
                      vm.addExercise(res);
                      await vm.save();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
