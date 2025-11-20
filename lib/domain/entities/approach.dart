class Approach {
  final int count;
  final int reps;
  final double? weight;

  Approach({
    required this.count,
    required this.reps,
    this.weight,
  });

  Approach copyWith({int? count, int? reps, double? weight}) =>
      Approach(count: count ?? this.count, reps: reps ?? this.reps, weight: weight ?? this.weight);
}
