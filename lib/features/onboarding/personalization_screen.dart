import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../providers/user_preferences_provider.dart';
import '../../providers/storage_provider.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    final fontOptions = [
      {'id': 'Lexend', 'name': 'Lexend', 'desc': 'Dirancang khusus untuk disleksia'},
      {'id': 'System', 'name': 'Standar', 'desc': 'Font sans-serif bersih'},
      {'id': 'OpenDyslexic', 'name': 'OpenDyslexic', 'desc': 'Dasar huruf tebal'},
    ];

    final colorOptions = [
      {'name': 'Warm Peach', 'color': const Color(0xFFFFF8F3), 'desc': 'Krem Peach (Anti Silau)'},
      {'name': 'Warm Cream', 'color': const Color(0xFFFDFBF7), 'desc': 'Krem Alami'},
      {'name': 'Soft Amber', 'color': const Color(0xFFFEF9EE), 'desc': 'Kuning Lembut'},
      {'name': 'Soft Mint', 'color': const Color(0xFFF2FAF4), 'desc': 'Hijau Tenang'},
      {'name': 'Light Gray', 'color': const Color(0xFFF8F9FA), 'desc': 'Abu Lembut'},
      {'name': 'White', 'color': const Color(0xFFFFFFFF), 'desc': 'Putih Bersih'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalisasi Tampilan'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Font Selector
                  _buildSectionHeader(
                    icon: Icons.font_download_rounded,
                    title: 'Pilihan Font',
                    subtitle: 'Pilih tipe huruf yang paling nyaman di matamu',
                  ),
                  const SizedBox(height: 12),
                  ...fontOptions.map((font) {
                    final isSelected = prefs.fontFamily == font['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          prefsNotifier.updatePreferences(prefs.copyWith(fontFamily: font['id']));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFEDD5) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFFEDD5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? const Color(0xFFEA580C) : Colors.black26,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      font['name']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? const Color(0xFF9A3412) : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    Text(
                                      font['desc']!,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Sliders Section
                  _buildSectionHeader(
                    icon: Icons.tune_rounded,
                    title: 'Ukuran & Kerapatan Teks',
                    subtitle: 'Atur agar mata tidak cepat lelah saat membaca',
                  ),
                  const SizedBox(height: 12),
                  
                  // Text Size Slider
                  _buildSliderCard(
                    title: 'Ukuran Teks',
                    valueDisplay: '${prefs.fontSize.toInt()} px',
                    child: Slider(
                      value: prefs.fontSize,
                      min: 16,
                      max: 28,
                      divisions: 6,
                      onChanged: (val) {
                        prefsNotifier.updatePreferences(prefs.copyWith(fontSize: val));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Letter Spacing Slider
                  _buildSliderCard(
                    title: 'Jarak Antar Huruf',
                    valueDisplay: '${(prefs.letterSpacing * 10).toInt() / 10} px',
                    child: Slider(
                      value: prefs.letterSpacing,
                      min: 0,
                      max: 2.0,
                      divisions: 4,
                      onChanged: (val) {
                        prefsNotifier.updatePreferences(prefs.copyWith(letterSpacing: val));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Line Height Slider
                  _buildSliderCard(
                    title: 'Jarak Antar Baris',
                    valueDisplay: '${(prefs.lineHeight * 10).toInt() / 10}x',
                    child: Slider(
                      value: prefs.lineHeight,
                      min: 1.2,
                      max: 2.2,
                      divisions: 5,
                      onChanged: (val) {
                        prefsNotifier.updatePreferences(prefs.copyWith(lineHeight: val));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Background Theme Swatches
                  _buildSectionHeader(
                    icon: Icons.palette_rounded,
                    title: 'Warna Latar Belakang',
                    subtitle: 'Warna lembut membantu mencegah kelelahan visual (Scotopic Stress)',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colorOptions.map((opt) {
                      final isSelected = prefs.backgroundTheme == opt['name'];
                      final colorVal = opt['color'] as Color;
                      return InkWell(
                        onTap: () {
                          prefsNotifier.updatePreferences(prefs.copyWith(backgroundTheme: opt['name'] as String));
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFFEDD5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: colorVal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                opt['name'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Live Preview Box
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_rounded, size: 18, color: Color(0xFFEA580C)),
                      const SizedBox(width: 8),
                      Text(
                        'Pratinjau Langsung (Live Preview)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(prefs.backgroundTheme),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Kartu Belajar 1',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Fotosintesis adalah proses di mana tumbuhan hijau mengubah cahaya matahari menjadi makanan untuk tumbuh kuat.',
                          style: TextStyle(
                            fontSize: prefs.fontSize,
                            letterSpacing: prefs.letterSpacing,
                            height: prefs.lineHeight,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Groq API Key Section
                  _buildApiKeyCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Sticky Bottom CTA Button
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final storage = ref.read(storageServiceProvider);
                    await storage.setOnboardingCompleted();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Mulai Belajar Sekarang'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDD5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFEA580C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueDisplay,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildApiKeyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFFEA580C)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groq API Key (AI Assistant)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      'Kunci rahasia untuk ekstraksi materi dengan AI',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Kunci API dapat disimpan di file `env.json` (otomatis aman di .gitignore) atau disimpan langsung di perangkat ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showApiKeyDialog(context),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Atur / Ubah API Key'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('groq_api_key') ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: Color(0xFFEA580C)),
              SizedBox(width: 10),
              Text('Groq API Key', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan API Key dari console.groq.com. Kunci ini hanya akan tersimpan secara lokal di memori HP/browser Anda.',
                style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'API Key (gsk_...)',
                  hintText: 'gsk_...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newKey = controller.text.trim();
                await prefs.setString('groq_api_key', newKey);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newKey.isEmpty ? 'API Key dihapus.' : 'API Key berhasil disimpan di perangkat!'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
