import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_diary/core/di/providers.dart';
import 'package:sports_diary/core/theme/design_tokens.dart';
import '../../../../domain/entities/program.dart';
import '../viewmodel/program_edit_viewmodel.dart';

class ProgramEditScreen extends ConsumerStatefulWidget {
  final Program? program;
  const ProgramEditScreen({Key? key, required this.program}) : super(key: key);

  @override
  ConsumerState<ProgramEditScreen> createState() => _ProgramEditScreenState();
}

class _ProgramEditScreenState extends ConsumerState<ProgramEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newDayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(programEditViewModelProvider(widget.program));
      vm.refreshFromRepo();
    });
  }

  @override
  void dispose() {
    _newDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(programEditViewModelProvider(widget.program));
    final isEditing = vm.editing != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование программы' : 'Создание программы'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Удалить программу',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Удалить программу?'),
                    content: Text('Вы точно уверены, что хотите удалить программу "${vm.name}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Удалить')),
                    ],
                  ),
                );
                if (ok == true) {
                  await vm.delete();
                  if (mounted) Navigator.of(context).pop(true);
                }
              },
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                initialValue: vm.name,
                decoration: const InputDecoration(labelText: 'Название программы'),
                onChanged: (v) => vm.name = v,
                validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newDayController,
                    decoration: const InputDecoration(hintText: 'Название тренировки (например "День ног")'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final name = _newDayController.text.trim();
                    if (name.isNotEmpty) {
                      vm.addTraining(name);
                      _newDayController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            vm.trainings.isEmpty
                ? const Center(child: Text('Тренировки не добавлены'))
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.trainings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final training = vm.trainings[i];
                return ListTile(
                  key: ValueKey(training.id),
                  title: Text(training.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editTrainingDialog(context, vm, training),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => vm.removeTraining(training.id),
                    ),
                  ]),
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: Text('Длина цикла (дней):', style: Theme.of(context).textTheme.bodyLarge)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: vm.cycleDays.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) {
                      final d = int.tryParse(v) ?? vm.cycleDays;
                      vm.setCycleDays(d);
                    },
                    decoration: const InputDecoration(isDense: true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text('Распределение тренировок по циклу', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.cycleDays,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final assignedId = (vm.schedule.length > idx) ? vm.schedule[idx] : null;
                final training = assignedId == null
                    ? null
                    : (vm.trainings.any((t) => t.id == assignedId)
                    ? vm.trainings.firstWhere((t) => t.id == assignedId)
                    : null);
                final title = training?.name ?? '— назначено: нет';
                return InkWell(
                  onTap: () async {
                    final picked = await showModalBottomSheet<String?>(
                      context: context,
                      builder: (_) => _buildAssignBottomSheet(context, vm, idx),
                    );
                    vm.assignTrainingToDay(idx, picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(color: DT.surface, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(child: Text('День ${idx + 1}', style: Theme.of(context).textTheme.bodyLarge)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(title, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
              } else {
                await vm.save();
                if (mounted) Navigator.of(context).pop(true);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAssignBottomSheet(BuildContext ctx, ProgramEditViewModel vm, int dayIndex) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Снять назначение'),
            onTap: () => Navigator.of(ctx).pop(null),
          ),
          const Divider(height: 1),
          ...vm.trainings.map((t) => ListTile(
            title: Text(t.name),
            onTap: () => Navigator.of(ctx).pop(t.id),
          )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _editTrainingDialog(BuildContext context, ProgramEditViewModel vm, dynamic training) {
    final controller = TextEditingController(text: training.name);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать тренировку'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) vm.renameTraining(training.id, newName);
              Navigator.of(context).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
