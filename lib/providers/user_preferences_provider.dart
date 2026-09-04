import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/storage_service.dart';
import '../models/user_preferences.dart';

import 'storage_provider.dart';

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    return ref.watch(storageServiceProvider).getPreferences();
  }

  Future<void> updatePreferences(UserPreferences newPrefs) async {
    state = newPrefs;
    await ref.read(storageServiceProvider).savePreferences(newPrefs);
  }

  Future<void> updateMode(LearningMode mode) async {
    UserPreferences newPrefs;
    if (mode == LearningMode.dyslexia) {
      newPrefs = UserPreferences.defaultDyslexia().copyWith(
        focusDuration: state.focusDuration,
        breakDuration: state.breakDuration,
      );
    } else if (mode == LearningMode.focus) {
      newPrefs = UserPreferences.defaultFocus().copyWith(
        focusDuration: state.focusDuration,
        breakDuration: state.breakDuration,
      );
    } else {
      newPrefs = state.copyWith(mode: mode);
    }
    await updatePreferences(newPrefs);
  }
}

final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(() {
  return UserPreferencesNotifier();
});
