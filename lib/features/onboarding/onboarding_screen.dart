import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Brand Hero Badge
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5), // Soft orange container
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 44,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Main Heading
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  children: const [
                    TextSpan(text: 'Selamat Datang di\n'),
                    TextSpan(
                      text: 'KeepUp! 🚀',
                      style: TextStyle(color: Color(0xFFEA580C)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Belajar lebih tenang, percaya diri,\ndan sesuai dengan ritme unik pikiranmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 36),
              // Mode Selector Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pilih Cara Belajar Terbaikmu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dyslexia Mode Card
              _ModeCard(
                iconEmoji: '📖',
                title: 'Mode Disleksia',
                badgeText: 'Font & Spasi Khusus',
                description: 'Teks dengan font Lexend yang dirancang khusus mengurangi stres visual dan huruf melompat.',
                highlightColor: const Color(0xFFF97316),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateMode(LearningMode.dyslexia);
                  context.push('/personalization');
                },
              ),
              const SizedBox(height: 16),
              // ADHD Focus Mode Card
              _ModeCard(
                iconEmoji: '🎯',
                title: 'Mode Fokus ADHD',
                badgeText: 'One Screen, One Idea',
                description: 'Potongan kalimat singkat per layar tanpa distraksi, dilengkapi timer fokus dan jeda relaksasi.',
                highlightColor: const Color(0xFFEA580C),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateMode(LearningMode.focus);
                  context.push('/personalization');
                },
              ),
              const SizedBox(height: 28),
              // Gentle Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kamu dapat menyesuaikan warna latar, ukuran teks, dan durasi kapan saja di Pengaturan.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9A3412),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String badgeText;
  final String description;
  final Color highlightColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.iconEmoji,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.highlightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: highlightColor.withOpacity(0.1),
        highlightColor: highlightColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Center(
                      child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFFF97316),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
