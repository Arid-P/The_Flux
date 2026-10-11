import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../focus/focus.dart';

final timerMinutesProvider = StateProvider<int>((ref) => 20);

/// ScreenDisciplinePage provides a simple test harness for screen discipline sessions.
class ScreenDisciplinePage extends ConsumerStatefulWidget {
  const ScreenDisciplinePage({super.key});

  @override
  ConsumerState<ScreenDisciplinePage> createState() => _ScreenDisciplinePageState();
}

class _ScreenDisciplinePageState extends ConsumerState<ScreenDisciplinePage> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(focusSessionProvider);
    final isBlocking = activeSession != null && activeSession.status.isActive;
    final selectedMinutes = ref.watch(timerMinutesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Discipline')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBlocking
                  ? 'Blocking Active: ${activeSession.elapsed.inMinutes}m elapsed'
                  : 'Selected Interval: $selectedMinutes min',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [2, 5, 10, 20].map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${m}m'),
                    selected: selectedMinutes == m,
                    onSelected: (val) {
                      if (val) ref.read(timerMinutesProvider.notifier).state = m;
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isBlocking) {
                  ref.read(focusSessionProvider.notifier).stopSession();
                } else {
                  ref.read(focusSessionProvider.notifier).startSession(
                        presetName: 'Discipline Block',
                        targetDuration: Duration(minutes: selectedMinutes),
                      );
                }
              },
              child: Text(isBlocking ? 'Stop Block' : 'Start Block'),
            ),
          ],
        ),
      ),
    );
  }
}
