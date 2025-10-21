import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sports_diary/presentation/features/calendar/view/calendar_screen.dart';
import 'package:sports_diary/presentation/features/profile/view/profile_screen.dart';
import 'package:sports_diary/presentation/features/programs/view/programs_screen.dart';
import 'package:sports_diary/presentation/features/statistics/view/statistic_screen.dart';

void main() {
  runApp(const ProviderScope(child: WorkoutDiaryApp()));
}

class BottomNavViewModel extends StateNotifier<int> {
  BottomNavViewModel() : super(0);
  void setIndex(int i) => state = i;
}

final bottomNavProvider = StateNotifierProvider<BottomNavViewModel, int>((ref) {
  return BottomNavViewModel();
});


class WorkoutDiaryApp extends ConsumerWidget {
  const WorkoutDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    final pages = const <Widget>[
      ProgramsScreen(),
      CalendarScreen(),
      StatisticsScreen(),
      ProfileScreen(),
    ];

    return MaterialApp(
      title: 'Workout Diary',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => ref.read(bottomNavProvider.notifier).setIndex(i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Программы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Календарь',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Статистика',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}