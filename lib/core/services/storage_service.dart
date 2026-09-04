import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/learning_material.dart';
import '../../models/user_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyMaterials = 'materials';
  static const String _keyPreferences = 'preferences';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  // --- Materials ---
  List<LearningMaterial> getMaterials() {
    final String? data = _prefs.getString(_keyMaterials);
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => LearningMaterial.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMaterials(List<LearningMaterial> materials) async {
    final String data = jsonEncode(materials.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyMaterials, data);
  }

  // --- Preferences ---
  UserPreferences getPreferences() {
    final String? data = _prefs.getString(_keyPreferences);
    if (data == null) return UserPreferences();
    
    try {
      final Map<String, dynamic> json = jsonDecode(data);
      return UserPreferences(
        mode: LearningMode.values.firstWhere(
          (e) => e.toString() == json['mode'],
          orElse: () => LearningMode.focus,
        ),
        fontFamily: json['fontFamily'] as String? ?? 'System',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
        letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.5,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
        backgroundTheme: json['backgroundTheme'] as String? ?? 'Light Gray',
        reduceMotion: json['reduceMotion'] as bool? ?? false,
        focusDuration: json['focusDuration'] as int? ?? 10,
        breakDuration: json['breakDuration'] as int? ?? 3,
      );
    } catch (e) {
      return UserPreferences();
    }
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    final Map<String, dynamic> json = {
      'mode': prefs.mode.toString(),
      'fontFamily': prefs.fontFamily,
      'fontSize': prefs.fontSize,
      'letterSpacing': prefs.letterSpacing,
      'lineHeight': prefs.lineHeight,
      'backgroundTheme': prefs.backgroundTheme,
      'reduceMotion': prefs.reduceMotion,
      'focusDuration': prefs.focusDuration,
      'breakDuration': prefs.breakDuration,
    };
    await _prefs.setString(_keyPreferences, jsonEncode(json));
  }

  // --- Onboarding ---
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }
}
