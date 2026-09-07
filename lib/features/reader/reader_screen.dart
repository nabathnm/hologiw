import 'dart:ui';
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

  void _nextPage() {
    if (_currentIndex < (ref.read(currentMaterialProvider)?.chunks.length ?? 0) - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
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
            // Top Bar: Clean, Minimal, Non-distracting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFEA580C)),
                      onPressed: () {
                        ref.read(focusSessionProvider.notifier).cancel();
                        context.pop();
                      },
                      tooltip: 'Keluar Sesi',
                    ),
                  ),
                  // Progress Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Kartu ${_currentIndex + 1} dari $totalChunks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                  // Timer Progress Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            value: sessionProgress,
                            strokeWidth: 2.5,
                            backgroundColor: const Color(0xFFFFEDD5),
                            color: const Color(0xFFF97316),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${focusState.durationMinutes - (focusState.elapsedSeconds / 60).floor()}m',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9A3412),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Flashcard Area: One Screen, One Idea
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: totalChunks,
                  itemBuilder: (context, index) {
                    final chunk = material.chunks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDD5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Ide #${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9A3412),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  chunk.content,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: prefs.fontSize + 4,
                                    height: prefs.lineHeight,
                                    letterSpacing: prefs.letterSpacing,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Navigation & Progress Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prev Button
                      IconButton.filledTonal(
                        onPressed: _currentIndex > 0 ? _prevPage : null,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        iconSize: 22,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEDD5),
                          foregroundColor: const Color(0xFFEA580C),
                          disabledBackgroundColor: Colors.black.withOpacity(0.04),
                          disabledForegroundColor: Colors.black26,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      // Swipe / Tap Hint
                      Text(
                        'Geser kartu atau tekan tombol',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Next Button
                      IconButton.filledTonal(
                        onPressed: _currentIndex < totalChunks - 1 ? _nextPage : null,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        iconSize: 22,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEDD5),
                          foregroundColor: const Color(0xFFEA580C),
                          disabledBackgroundColor: Colors.black.withOpacity(0.04),
                          disabledForegroundColor: Colors.black26,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFFFEDD5),
                      color: const Color(0xFFF97316),
                      minHeight: 8,
                    ),
                  ),
                  // Completion Button
                  if (_currentIndex == totalChunks - 1) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF16A34A), // Success Green
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          ref.read(materialsProvider.notifier).updateProgress(material.id, totalChunks);
                          _finishSession();
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Selesai Membaca 🏆', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
