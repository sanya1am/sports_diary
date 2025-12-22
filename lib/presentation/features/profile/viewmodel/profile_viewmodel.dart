import 'package:flutter/foundation.dart';
import '../../../../domain/entities/measurement.dart';
import '../../../../domain/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repo;

  List<Measurement> measurements = [];
  bool loading = false;
  String? error;

  static const kHeightName = 'Рост';
  static const kWeightName = 'Вес';

  ProfileViewModel({required this.repo});

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      measurements = await repo.getAll();
    } catch (e) {
      error = e.toString();
      measurements = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Measurement? getById(String id) {
    try {
      return measurements.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  Measurement? getByName(String name) {
    try {
      return measurements.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  Measurement? getHeight() => getByName(kHeightName);
  Measurement? getWeight() => getByName(kWeightName);

  Future<void> setHeight(double value) async {
    await _upsert(kHeightName, value);
  }

  Future<void> setWeight(double value) async {
    await _upsert(kWeightName, value);
  }

  Future<void> addMeasurement(Measurement m) async {
    await repo.save(m);
    await load();
  }

  Future<void> updateMeasurement(Measurement m) async {
    await repo.save(m);
    await load();
  }

  Future<void> deleteMeasurement(String id) async {
    await repo.delete(id);
    await load();
  }

  Future<void> _upsert(String name, double value) async {
    final existing = getByName(name);
    final now = DateTime.now();
    if (existing != null) {
      final updated = existing.copyWith(value: value, updatedAt: now);
      await repo.save(updated);
    } else {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final m = Measurement(id: id, name: name, value: value, createdAt: now);
      await repo.save(m);
    }
    await load();
  }
}
