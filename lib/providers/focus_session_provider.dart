import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusState { idle, running, paused, completed, breakTime }

class FocusSessionState {
  final FocusState status;
  final int durationMinutes;
  final DateTime? startTime;
  final int elapsedSeconds;

  FocusSessionState({
    required this.status,
    required this.durationMinutes,
    this.startTime,
    this.elapsedSeconds = 0,
  });

  FocusSessionState copyWith({
    FocusState? status,
    int? durationMinutes,
    DateTime? startTime,
    int? elapsedSeconds,
  }) {
    return FocusSessionState(
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class FocusSessionNotifier extends Notifier<FocusSessionState> {
  Timer? _timer;

  @override
  FocusSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return FocusSessionState(status: FocusState.idle, durationMinutes: 10);
  }

  void setup(int minutes) {
    state = FocusSessionState(status: FocusState.idle, durationMinutes: minutes);
  }

  void start() {
    if (state.status == FocusState.running) return;

    state = state.copyWith(
      status: FocusState.running,
      startTime: DateTime.now().subtract(Duration(seconds: state.elapsedSeconds)),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status != FocusState.running) {
        timer.cancel();
        return;
      }
      
      final now = DateTime.now();
      final diff = now.difference(state.startTime!).inSeconds;
      
      if (diff >= state.durationMinutes * 60) {
        complete();
      } else {
        state = state.copyWith(elapsedSeconds: diff);
      }
    });
  }

  void pause() {
    state = state.copyWith(status: FocusState.paused);
    _timer?.cancel();
  }

  void resume() {
    start();
  }

  void complete() {
    _timer?.cancel();
    state = state.copyWith(status: FocusState.completed);
  }

  void startBreak() {
    state = state.copyWith(status: FocusState.breakTime);
  }

  void cancel() {
    _timer?.cancel();
    state = FocusSessionState(status: FocusState.idle, durationMinutes: state.durationMinutes);
  }
}

final focusSessionProvider = NotifierProvider<FocusSessionNotifier, FocusSessionState>(() {
  return FocusSessionNotifier();
});
