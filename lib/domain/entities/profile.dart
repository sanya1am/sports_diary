import 'measurement.dart';

class Profile {
  final List<Measurement> measurements;

  Profile({required this.measurements});

  Profile copyWith({List<Measurement>? measurements}) =>
      Profile(measurements: measurements ?? this.measurements);

  Measurement? getByName(String name) {
    try {
      return measurements.firstWhere((m) => m.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}