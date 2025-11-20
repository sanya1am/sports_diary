import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/exercise.dart';
import '../viewmodel/exercise_add_viewmodel.dart';
import 'package:sports_diary/core/di/providers.dart';

class ExerciseAddScreen extends ConsumerStatefulWidget {
  final Exercise? exercise;
  const ExerciseAddScreen({Key? key, this.exercise}) : super(key: key);

  @override
  ConsumerState<ExerciseAddScreen> createState() => _ExerciseAddScreenState();
}

class _ExerciseAddScreenState extends ConsumerState<ExerciseAddScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final vm = ref.read(exerciseAddViewModelProvider(widget.exercise));
    vm.init(exercise: widget.exercise);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _addAndScroll() async {
    final vm = ref.read(exerciseAddViewModelProvider(widget.exercise));
    vm.addApproach();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(exerciseAddViewModelProvider(widget.exercise));
    final isEdit = widget.exercise != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать упражнение' : 'Добавить упражнение')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: vm.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      hintText: 'Жим лёжа, Присед и т.д.',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: vm.muscleGroup,
                    decoration: const InputDecoration(labelText: 'Мышечная группа (опционально)'),
                    items: [null, ...vm.muscleGroups]
                        .map((g) => DropdownMenuItem<String>(value: g, child: Text(g ?? 'Не указано')))
                        .toList(),
                    onChanged: (v) => vm.setMuscleGroup(v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Подходы (кол-во, повторы, вес в кг)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (vm.approachesCount == 0)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(child: Text('Подходы не добавлены')),
                              )
                            else
                              Column(
                                children: List.generate(vm.approachesCount, (i) {
                                  return Column(
                                    children: [
                                      _buildApproachRow(vm, i),
                                      if (i != vm.approachesCount - 1)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.0),
                                          child: Divider(height: 1),
                                        ),
                                    ],
                                  );
                                }),
                              ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Добавить подход'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _addAndScroll,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Отдых между подходами'),
                        Switch(value: vm.restBetweenApproaches, onChanged: vm.setRestBetween),
                      ],
                    ),

                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final ex = vm.buildExercise();
              if (ex == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите название упражнения')));
                return;
              }
              Navigator.of(context).pop(ex);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildApproachRow(ExerciseAddViewModel vm, int index) {
    final countCtrl = vm.approachCountController(index);
    final repsCtrl = vm.approachRepsController(index);
    final weightCtrl = vm.approachWeightController(index);

    const fieldGap = 8.0;
    const iconSize = 22.0;

    final inputDecoration = const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: OutlineInputBorder(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: TextFormField(
              controller: countCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Подх.'),
            ),
          ),

          const SizedBox(width: fieldGap),

          Flexible(
            flex: 3,
            child: TextFormField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Повт.'),
            ),
          ),

          const SizedBox(width: fieldGap),

          Flexible(
            flex: 3,
            child: TextFormField(
              controller: weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Вес (кг)'),
            ),
          ),

          const SizedBox(width: fieldGap),

          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36, maxWidth: 36, minHeight: 36, maxHeight: 36),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: iconSize,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => vm.removeApproach(index),
            ),
          ),
        ],
      ),
    );
  }
}
