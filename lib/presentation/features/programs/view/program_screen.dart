import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_diary/core/di/providers.dart';
import 'package:sports_diary/presentation/features/programs/view/program_edit_screen.dart';
import 'package:sports_diary/presentation/features/programs/view/training_screen.dart';


class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(programViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(vm.selected?.name ?? 'Нет выбранной программы')),
            PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (value) async {
                if (value == '__create__') {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProgramEditScreen(program: null),
                    ),
                  );
                  if (created == true) await ref.read(programViewModelProvider).load();
                } else {
                  await ref.read(programViewModelProvider).selectById(value);
                }
              },
              itemBuilder: (ctx) {
                final items = <PopupMenuEntry<String>>[];
                for (final p in vm.programs) {
                  items.add(
                    PopupMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    ),
                  );
                }
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem(
                    value: '__create__',
                    child: ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Создать новую программу'),
                    ),
                  ),
                );
                return items;
              },
            ),
            const SizedBox(width: 8),

            if (vm.selected != null)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Редактировать программу',
                onPressed: () async {
                  final selected = vm.selected!;
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProgramEditScreen(program: selected),
                    ),
                  );
                  if (res == true) {
                    await ref.read(programViewModelProvider).refreshSelectedFromRepo();
                  }
                },
              ),
          ],
        ),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.selected == null
          ? const Center(child: Text('Программ нет. Создайте новую.'))
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: vm.selected!.trainings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final training = vm.selected!.trainings[index];
                return ListTile(
                  title: Text(training.name),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  onTap: () async {
                    final res = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => TrainingDayScreen(
                          programId: vm.selected!.id,
                          trainingId: training.id,
                        ),
                      ),
                    );
                    if (res == true) {
                      await ref.read(programViewModelProvider).load();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}