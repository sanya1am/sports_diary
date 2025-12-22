import 'package:hive/hive.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/measurement_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Box settingsBox;
  static const _key = 'measurements';

  ProfileRepositoryImpl({required this.settingsBox});

  Map<String, dynamic> _readRawMap() {
    final raw = settingsBox.get(_key);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  Future<void> _writeRawMap(Map<String, dynamic> m) async {
    await settingsBox.put(_key, m);
  }

  @override
  Future<void> delete(String id) async {
    final raw = _readRawMap();
    raw.remove(id);
    await _writeRawMap(raw);
  }

  @override
  Future<List<Measurement>> getAll() async {
    final raw = _readRawMap();
    final result = <Measurement>[];
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is Map) {
        try {
          final mm = MeasurementModel.fromMap(Map<String, dynamic>.from(value));
          result.add(mm.toDomain());
        } catch (_) {}
      }
    }
    // сортировка по createdAt
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<Measurement?> getById(String id) async {
    final raw = _readRawMap();
    final v = raw[id];
    if (v is Map) {
      return MeasurementModel.fromMap(Map<String, dynamic>.from(v)).toDomain();
    }
    return null;
  }

  @override
  Future<Measurement?> getByName(String name) async {
    final list = await getAll();
    try {
      return list.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Measurement m) async {
    final raw = _readRawMap();
    final model = MeasurementModel.fromDomain(m);
    raw[m.id] = model.toMap();
    await _writeRawMap(raw);
  }
}
