import '../entities/measurement.dart';


abstract class ProfileRepository {
  Future<List<Measurement>> getAll();
  Future<void> save(Measurement m);
  Future<void> delete(String id);
  Future<Measurement?> getById(String id);
  Future<Measurement?> getByName(String name);
}