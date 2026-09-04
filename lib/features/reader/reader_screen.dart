import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/materials_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/user_preferences_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final material = ref.read(currentMaterialProvider);
    _currentIndex = material?.currentChunkIndex ?? 0;
    if (material != null && _currentIndex >= material.chunks.length) {
      _currentIndex = 0; // reset if completed
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    final material = ref.read(currentMaterialProvider);
    if (material != null) {
      ref.read(materialsProvider.notifier).updateProgress(material.id, index);
    }
  }

  void _finishSession() {
    ref.read(focusSessionProvider.notifier).startBreak();
    context.pushReplacement('/calm-break');
  }

  @override
  Widget build(BuildContext context) {
    final material = ref.watch(currentMaterialProvider);
    final focusState = ref.watch(focusSessionProvider);
    final prefs = ref.watch(userPreferencesProvider);

    if (material == null) return const Scaffold();

    if (focusState.status == FocusState.completed) {
      // Defer navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishSession();
      });
    }

    final totalChunks = material.chunks.length;
    final progress = totalChunks == 0 ? 0.0 : (_currentIndex + 1) / totalChunks;
    
    // Focus timer progress
    final totalSeconds = focusState.durationMinutes * 60;
    final sessionProgress = focusState.elapsedSeconds / totalSeconds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(focusSessionProvider.notifier).cancel();
                      context.pop();
                    },
                    tooltip: 'Keluar',
                  ),
                  Text(
                    '${_currentIndex + 1} / $totalChunks',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: sessionProgress,
                          backgroundColor: Colors.black12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Icon(Icons.timer, size: 16, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: totalChunks,
                itemBuilder: (context, index) {
                  final chunk = material.chunks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                    child: Center(
                      child: Text(
                        chunk.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: prefs.fontSize + 4,
                          height: prefs.lineHeight,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Hint and Progress
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    '← swipe →',
                    style: TextStyle(color: Colors.black38, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black12,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                  if (_currentIndex == totalChunks - 1) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Mark complete
                        ref.read(materialsProvider.notifier).updateProgress(material.id, totalChunks);
                        _finishSession();
                      },
                      child: const Text('Selesai Membaca'),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
