import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/materials_provider.dart';
import '../../providers/focus_session_provider.dart';

class FocusSetupScreen extends ConsumerWidget {
  const FocusSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final material = ref.watch(currentMaterialProvider);
    final focusState = ref.watch(focusSessionProvider);

    if (material == null) {
      return const Scaffold(body: Center(child: Text('Materi tidak ditemukan')));
    }

    // Estimate: let's say 1 minute per 2 chunks (arbitrary, just for display)
    final estimateMinutes = (material.chunks.length / 2).ceil();
    final isDone = material.currentChunkIndex >= material.chunks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi siap dipelajari'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${material.chunks.length} kartu belajar',
                      style: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estimasi: ±$estimateMinutes menit',
                      style: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Berapa lama kamu ingin fokus?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [10, 15, 20].map((minutes) {
                        final isSelected = focusState.durationMinutes == minutes;
                        return ChoiceChip(
                          label: Text('$minutes menit'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(focusSessionProvider.notifier).setup(minutes);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(focusSessionProvider.notifier).start();
                  context.pushReplacement('/reader');
                },
                child: Text(isDone ? 'Baca Lagi' : 'Mulai Belajar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
