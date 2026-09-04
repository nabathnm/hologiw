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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isFinished ? 'Istirahat selesai' : 'Saatnya istirahat 🌿',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isFinished ? 'Siap melanjutkan?' : 'Tarik napas...\nHembuskan perlahan...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54, height: 1.5),
              ),
              const Spacer(),
              
              if (!_isFinished && !prefs.reduceMotion)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              if (_isFinished)
                const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),

              const Spacer(),
              
              if (!_isFinished) ...[
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black12,
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _finish,
                  child: const Text('Lewati istirahat', style: TextStyle(color: Colors.black54)),
                )
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finish,
                    child: const Text('Lanjutkan Belajar'),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
