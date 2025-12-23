import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/providers.dart';
import '../viewmodel/calendar_viewmodel.dart';
import '../../programs/viewmodel/program_viewmodel.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final programVm = ref.read(programViewModelProvider);
    final selected = programVm.selected;
    if (selected != null) {
      final vm = ref.read(calendarViewModelProvider(selected.id));
      vm.computeMonth(currentMonth.year, currentMonth.month);
    }
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
    _recompute();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
    _recompute();
  }

  void _recompute() {
    final programVm = ref.read(programViewModelProvider);
    final selected = programVm.selected;
    if (selected != null) {
      ref.read(calendarViewModelProvider(selected.id)).computeMonth(currentMonth.year, currentMonth.month);
    }
  }

  Future<void> _pickStartDate(String programId) async {
    final initial = ref.read(calendarViewModelProvider(programId)).startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      await ref.read(calendarViewModelProvider(programId)).setStartDate(picked);
      await ref.read(calendarViewModelProvider(programId)).computeMonth(currentMonth.year, currentMonth.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final programVm = ref.watch(programViewModelProvider);
    final selected = programVm.selected;

    if (selected == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Календарь')),
        body: const Center(child: Text('Выберите программу тренировок в верхнем меню')),
      );
    }

    final vm = ref.watch(calendarViewModelProvider(selected.id));

    final firstOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final weekdayOfFirst = firstOfMonth.weekday;
    final leadingEmpty = weekdayOfFirst % 7;
    final startWeekdayIndex = (weekdayOfFirst - 1);

    final lastOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final totalDays = lastOfMonth.day;
    final totalCells = startWeekdayIndex + totalDays;
    final rows = (totalCells / 7).ceil();

    return Scaffold(
      appBar: AppBar(title: Text('Календарь — ${selected.name}')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat.yMMMM().format(currentMonth),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: vm.startDate == null
                      ? Text('Дата старта не установлена', style: Theme.of(context).textTheme.bodyMedium)
                      : Text('Дата старта: ${DateFormat.yMMMd().format(vm.startDate!)}', style: Theme.of(context).textTheme.bodyMedium),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(vm.startDate == null ? 'Установить старт' : 'Изменить'),
                  onPressed: () => _pickStartDate(selected.id),
                ),
                if (vm.startDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Удалить дату старта',
                    onPressed: () async {
                      await ref.read(calendarViewModelProvider(selected.id)).clearStartDate();
                      ref.read(calendarViewModelProvider(selected.id)).computeMonth(currentMonth.year, currentMonth.month);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: const [
                Expanded(child: Center(child: Text('Пн'))),
                Expanded(child: Center(child: Text('Вт'))),
                Expanded(child: Center(child: Text('Ср'))),
                Expanded(child: Center(child: Text('Чт'))),
                Expanded(child: Center(child: Text('Пт'))),
                Expanded(child: Center(child: Text('Сб'))),
                Expanded(child: Center(child: Text('Вс'))),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: GridView.builder(
                itemCount: rows * 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.1),
                itemBuilder: (context, index) {
                  final cellIndex = index;
                  final dayNumber = cellIndex - startWeekdayIndex + 1;
                  if (dayNumber < 1 || dayNumber > totalDays) {
                    return const SizedBox.shrink();
                  }
                  final dayDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                  final isTraining = vm.isTrainingDay(dayDate);

                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () {
                        // в будущем: показать детализацию дня / тренировку
                        if (isTraining) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Это день тренировки')));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isTraining ? Theme.of(context).colorScheme.surface.withOpacity(0.04) : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text('$dayNumber', style: Theme.of(context).textTheme.bodyLarge),
                              ),
                            ),
                            if (isTraining)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
