// lib/presentation/features/profile/view/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_diary/presentation/features/profile/viewmodel/profile_viewmodel.dart';
import '../../../../core/di/providers.dart';
import '../../../../domain/entities/measurement.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем данные после первого кадра (vm доступен через ref)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(profileViewModelProvider);

    final height = vm.getHeight();
    final weight = vm.getWeight();
    final other = vm.measurements
        .where((m) => m.name != ProfileViewModel.kHeightName && m.name != ProfileViewModel.kWeightName)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Карточка основных параметров
            Card(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(
                      context,
                      title: 'Рост',
                      value: height?.value?.toString() ?? '-',
                      onEdit: () async {
                        final updated = await _showMeasurementDialog(context, existing: height, initialName: ProfileViewModel.kHeightName);
                        if (updated != null) {
                          // если редактируем рост — используем setHeight
                          await ref.read(profileViewModelProvider).setHeight(updated.value ?? 0);
                        }
                      },
                    ),
                    _buildStatColumn(
                      context,
                      title: 'Вес',
                      value: weight?.value?.toString() ?? '-',
                      onEdit: () async {
                        final updated = await _showMeasurementDialog(context, existing: weight, initialName: ProfileViewModel.kWeightName);
                        if (updated != null) {
                          await ref.read(profileViewModelProvider).setWeight(updated.value ?? 0);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Заголовок секции замеров
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Замеры', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),

            // Список дополнительных замеров — ListView.separated (корректные разделители)
            Expanded(
              child: other.isEmpty
                  ? const Center(child: Text('Нет замеров'))
                  : ListView.separated(
                itemCount: other.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final m = other[index];
                  return ListTile(
                    title: Text(m.name),
                    subtitle: Text(m.value?.toString() ?? '-'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updated = await _showMeasurementDialog(context, existing: m);
                            if (updated != null) {
                              await ref.read(profileViewModelProvider).updateMeasurement(updated);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Подтверждение удаления
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Удалить замер?'),
                                content: Text('Вы точно хотите удалить "${m.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
                                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Удалить')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ref.read(profileViewModelProvider).deleteMeasurement(m.id);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка добавить замер
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Добавить замер'),
                onPressed: () async {
                  final newM = await _showMeasurementDialog(context);
                  if (newM != null) {
                    await ref.read(profileViewModelProvider).addMeasurement(newM);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, {required String title, required String value, required VoidCallback onEdit}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          ),
        ],
      ),
    );
  }

  Future<Measurement?> _showMeasurementDialog(BuildContext context, {Measurement? existing, String? initialName}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? initialName ?? '');
    final valueCtrl = TextEditingController(text: existing?.value?.toString() ?? '');

    return showDialog<Measurement>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Новый замер' : 'Редактировать замер'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название замера')),
            const SizedBox(height: 8),
            TextField(
              controller: valueCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Значение'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final raw = valueCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите название')));
                return;
              }
              final val = double.tryParse(raw.replaceAll(',', '.'));
              if (val == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный формат значения')));
                return;
              }

              final now = DateTime.now();
              if (existing != null) {
                final updated = existing.copyWith(name: name, value: val, updatedAt: now);
                Navigator.of(context).pop(updated);
              } else {
                final id = DateTime.now().microsecondsSinceEpoch.toString();
                final m = Measurement(id: id, name: name, value: val, createdAt: now);
                Navigator.of(context).pop(m);
              }
            },
            child: const Text('Сохранить'),
          )
        ],
      ),
    );
  }
}
