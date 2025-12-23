import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:sports_diary/domain/repositories/program_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final ProgramRepository repo;
  final Box settingsBox;
  final String programId;

  DateTime? startDate;
  int cycleDays = 7;
  List<String?> schedule = [];

  bool loading = false;
  String? error;

  Set<DateTime> monthTrainingDays = {};

  CalendarViewModel({
    required this.repo,
    required this.settingsBox,
    required this.programId,
  });

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final p = await repo.getById(programId);
      if (p == null) {
        error = 'Program not found';
        cycleDays = 7;
        schedule = [];
      } else {
        cycleDays = p.cycleDays;
        schedule = List<String?>.from(p.schedule);
      }

      final sd = settingsBox.get(_settingsKey);
      if (sd is String) {
        try {
          startDate = DateTime.parse(sd);
        } catch (_) {
          startDate = null;
        }
      } else {
        startDate = null;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String get _settingsKey => 'calendar_start_$programId';

  Future<void> setStartDate(DateTime d) async {
    startDate = DateTime(d.year, d.month, d.day);
    await settingsBox.put(_settingsKey, startDate!.toIso8601String());
    notifyListeners();
  }

  Future<void> clearStartDate() async {
    startDate = null;
    await settingsBox.delete(_settingsKey);
    monthTrainingDays = {};
    notifyListeners();
  }

  Future<void> computeMonth(int year, int month) async {
    monthTrainingDays = {};
    if (startDate == null) {
      notifyListeners();
      return;
    }
    final p = await repo.getById(programId);
    if (p != null) {
      cycleDays = p.cycleDays;
      schedule = List<String?>.from(p.schedule);
    }

    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);

    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
      if (d.isBefore(startDate!)) continue;
      final daysSince = d.difference(startDate!).inDays;
      if (cycleDays <= 0) continue;
      final pos = daysSince % cycleDays;
      final assigned = (pos >= 0 && pos < schedule.length) ? schedule[pos] : null;
      if (assigned != null) {
        monthTrainingDays.add(DateTime(d.year, d.month, d.day));
      }
    }
    notifyListeners();
  }

  bool isTrainingDay(DateTime date) {
    final lookup = DateTime(date.year, date.month, date.day);
    return monthTrainingDays.contains(lookup);
  }
}
