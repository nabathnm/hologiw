import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../providers/focus_session_provider.dart';
import '../../providers/user_preferences_provider.dart';

class CalmBreakScreen extends ConsumerStatefulWidget {
  const CalmBreakScreen({super.key});

  @override
  ConsumerState<CalmBreakScreen> createState() => _CalmBreakScreenState();
}

class _CalmBreakScreenState extends ConsumerState<CalmBreakScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _breakTimer;
  int _secondsLeft = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // 4s inhale
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );

    _controller.addStatusListener((status) async {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        // Hold for 2s
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Exhale done, wait 2s
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) _controller.forward();
      }
    });

    _controller.forward();

    // Setup Break Timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(userPreferencesProvider);
      _secondsLeft = prefs.breakDuration * 60;
      
      _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _isFinished = true;
            timer.cancel();
            _controller.stop();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _breakTimer?.cancel();
    super.dispose();
  }

  void _finish() {
    ref.read(focusSessionProvider.notifier).cancel();
    context.go('/'); // Return to home
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final totalBreakSeconds = prefs.breakDuration * 60;
    final progress = totalBreakSeconds > 0 ? 1 - (_secondsLeft / totalBreakSeconds) : 1.0;

    final isExpanding = _controller.status == AnimationStatus.forward;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Header Title
              Text(
                _isFinished ? 'Istirahat Selesai! 🎉' : 'Saatnya Jeda & Bernapas 🌿',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isFinished
                    ? 'Pikiranmu sudah segar kembali dan siap untuk langkah selanjutnya!'
                    : (isExpanding ? 'Tarik napas perlahan... 🍃' : 'Hembuskan napas perlahan... 💨'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _isFinished ? const Color(0xFF15803D) : const Color(0xFFEA580C),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              
              // Breathing Concentric Rings with Warm Sunset Glow
              if (!_isFinished && !prefs.reduceMotion)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFEDD5).withValues(alpha: 0.4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withValues(alpha: 0.2),
                              blurRadius: 36,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFDBA74).withValues(alpha: 0.6),
                            ),
                            child: Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF97316),
                                ),
                                child: const Center(
                                  child: Icon(Icons.air_rounded, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              if (_isFinished)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, size: 68, color: Color(0xFF16A34A)),
                  ),
                ),

              const Spacer(),
              
              if (!_isFinished) ...[
                // Timer Countdown Display
                Text(
                  '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFFFEDD5),
                    color: const Color(0xFFF97316),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _finish,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text(
                    'Lewati Istirahat',
                    style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
                )
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _finish,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Lanjutkan Belajar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
