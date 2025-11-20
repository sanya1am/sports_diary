import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../../domain/entities/approach.dart';

class _ApproachControllers {
  final TextEditingController countC;
  final TextEditingController repsC;
  final TextEditingController weightC;

  _ApproachControllers({
    required int count,
    required int reps,
    double? weight,
  })  : countC = TextEditingController(text: count.toString()),
        repsC = TextEditingController(text: reps.toString()),
        weightC = TextEditingController(text: weight?.toString() ?? '');

  Approach toApproach() {
    final count = int.tryParse(countC.text.trim()) ?? 1;
    final reps = int.tryParse(repsC.text.trim()) ?? 0;
    final w = double.tryParse(weightC.text.trim());
    return Approach(count: count <= 0 ? 1 : count, reps: reps < 0 ? 0 : reps, weight: w);
  }

  void dispose() {
    countC.dispose();
    repsC.dispose();
    weightC.dispose();
  }
}

class ExerciseAddViewModel extends ChangeNotifier {
  final _uuid = const Uuid();
  final TextEditingController nameController = TextEditingController();

  bool restBetweenApproaches = false;

  final List<_ApproachControllers> _approachCtrls = [];
  List<Approach> get approaches => _approachCtrls.map((c) => c.toApproach()).toList();

  String? muscleGroup;
  final List<String> muscleGroups;
  Exercise? editing;

  ExerciseAddViewModel({this.muscleGroups = const ['Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Кардио']});

  void init({Exercise? exercise}) {
    editing = exercise;
    if (exercise != null) {
      nameController.text = exercise.name;
      muscleGroup = exercise.muscleGroup;
      restBetweenApproaches = exercise.restBetweenApproaches;
      _approachCtrls.clear();
      for (final a in exercise.approaches) {
        _approachCtrls.add(_ApproachControllers(count: a.count, reps: a.reps, weight: a.weight));
      }
      if (_approachCtrls.isEmpty) {
        _approachCtrls.add(_ApproachControllers(count: 1, reps: 10, weight: null));
      }
    } else {
      nameController.text = '';
      muscleGroup = null;
      restBetweenApproaches = false;
      _approachCtrls.clear();
      _approachCtrls.add(_ApproachControllers(count: 1, reps: 10, weight: null));
    }
    notifyListeners();
  }

  void addApproach() {
    _approachCtrls.add(_ApproachControllers(count: 1, reps: 10, weight: null));
    notifyListeners();
  }

  void removeApproach(int index) {
    if (index < 0 || index >= _approachCtrls.length) return;
    _approachCtrls[index].dispose();
    _approachCtrls.removeAt(index);
    notifyListeners();
  }

  void setMuscleGroup(String? g) {
    muscleGroup = g;
    notifyListeners();
  }

  void setRestBetween(bool v) {
    restBetweenApproaches = v;
    notifyListeners();
  }

  Exercise? buildExercise() {
    final name = nameController.text.trim();
    if (name.isEmpty) return null;
    final id = editing?.id ?? _uuid.v4();
    final aps = approaches;
    return Exercise(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      approaches: aps,
      restBetweenApproaches: restBetweenApproaches,
    );
  }

  int get approachesCount => _approachCtrls.length;

  TextEditingController approachCountController(int index) => _approachCtrls[index].countC;
  TextEditingController approachRepsController(int index) => _approachCtrls[index].repsC;
  TextEditingController approachWeightController(int index) => _approachCtrls[index].weightC;

  @override
  void dispose() {
    for (final c in _approachCtrls) c.dispose();
    nameController.dispose();
    super.dispose();
  }
}
