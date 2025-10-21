import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_diary/core/di/providers.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programsViewModelProvider);
    final vm = ref.read(programsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои программы')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: state.programs.length,
        itemBuilder: (context, index) {
          final p = state.programs[index];
          return ListTile(
            title: Text(p.name),
            subtitle: Text('${p.daysCount} дней'),
            onTap: () => vm.openProgram(p.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.createNewProgram,
        child: const Icon(Icons.add),
      ),
    );
  }
}