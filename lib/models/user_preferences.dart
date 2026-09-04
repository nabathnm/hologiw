enum LearningMode { dyslexia, focus, custom }

class UserPreferences {
  final LearningMode mode;
  final String fontFamily;
  final double fontSize;
  final double letterSpacing;
  final double lineHeight;
  final String backgroundTheme;
  final bool reduceMotion;
  final int focusDuration;
  final int breakDuration;

  UserPreferences({
    this.mode = LearningMode.focus,
    this.fontFamily = 'System',
    this.fontSize = 20.0,
    this.letterSpacing = 0.5,
    this.lineHeight = 1.6,
    this.backgroundTheme = 'Warm Cream',
    this.reduceMotion = false,
    this.focusDuration = 10,
    this.breakDuration = 3,
  });

  UserPreferences copyWith({
    LearningMode? mode,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? lineHeight,
    String? backgroundTheme,
    bool? reduceMotion,
    int? focusDuration,
    int? breakDuration,
  }) {
    return UserPreferences(
      mode: mode ?? this.mode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
    );
  }

  factory UserPreferences.defaultDyslexia() {
    return UserPreferences(
      mode: LearningMode.dyslexia,
      fontFamily: 'OpenDyslexic',
      fontSize: 22.0,
      letterSpacing: 1.0,
      lineHeight: 1.8,
      backgroundTheme: 'Warm Cream',
    );
  }

  factory UserPreferences.defaultFocus() {
    return UserPreferences(
      mode: LearningMode.focus,
      fontFamily: 'System',
      fontSize: 20.0,
      letterSpacing: 0.5,
      lineHeight: 1.6,
      backgroundTheme: 'Light Gray',
    );
  }
}
