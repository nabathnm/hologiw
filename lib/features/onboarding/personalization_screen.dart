import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_preferences_provider.dart';
import '../../providers/storage_provider.dart';
import '../../core/services/storage_service.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesuaikan pengalaman belajarmu'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _SectionTitle('Font'),
                  DropdownButtonFormField<String>(
                    value: prefs.fontFamily,
                    items: ['System', 'OpenDyslexic'].map((font) {
                      return DropdownMenuItem(value: font, child: Text(font));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        prefsNotifier.updatePreferences(prefs.copyWith(fontFamily: val));
                      }
                    },
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Ukuran Teks (${prefs.fontSize.toInt()})'),
                  Slider(
                    value: prefs.fontSize,
                    min: 16,
                    max: 28,
                    divisions: 6,
                    onChanged: (val) {
                      prefsNotifier.updatePreferences(prefs.copyWith(fontSize: val));
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Jarak Huruf (${prefs.letterSpacing})'),
                  Slider(
                    value: prefs.letterSpacing,
                    min: 0,
                    max: 2.0,
                    divisions: 4,
                    onChanged: (val) {
                      prefsNotifier.updatePreferences(prefs.copyWith(letterSpacing: val));
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Jarak Baris (${prefs.lineHeight})'),
                  Slider(
                    value: prefs.lineHeight,
                    min: 1.2,
                    max: 2.0,
                    divisions: 4,
                    onChanged: (val) {
                      prefsNotifier.updatePreferences(prefs.copyWith(lineHeight: val));
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Warna Latar'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      'White',
                      'Warm Cream',
                      'Soft Blue',
                      'Soft Green',
                      'Light Gray'
                    ].map((colorName) {
                      final isSelected = prefs.backgroundTheme == colorName;
                      return ChoiceChip(
                        label: Text(colorName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            prefsNotifier.updatePreferences(prefs.copyWith(backgroundTheme: colorName));
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'Fotosintesis adalah proses yang digunakan tumbuhan untuk membuat makanan.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final storage = ref.read(storageServiceProvider);
                    await storage.setOnboardingCompleted();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                  child: const Text('Mulai Belajar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
