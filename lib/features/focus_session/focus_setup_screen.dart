import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/materials_provider.dart';
import '../../providers/focus_session_provider.dart';

class FocusSetupScreen extends ConsumerWidget {
  const FocusSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final material = ref.watch(currentMaterialProvider);
    final focusState = ref.watch(focusSessionProvider);

    if (material == null) {
      return const Scaffold(body: Center(child: Text('Materi tidak ditemukan')));
    }

    final estimateMinutes = (material.chunks.length / 2).ceil();
    final isDone = material.chunks.isNotEmpty && material.currentChunkIndex >= material.chunks.length;

    final durationOptions = [
      {'minutes': 5, 'label': '5 Menit', 'desc': 'Kilat'},
      {'minutes': 10, 'label': '10 Menit', 'desc': 'Ideal'},
      {'minutes': 15, 'label': '15 Menit', 'desc': 'Fokus'},
      {'minutes': 20, 'label': '20 Menit', 'desc': 'Mendalam'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persiapan Sesi Belajar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Material Highlight Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.school_rounded, color: Color(0xFFEA580C), size: 30),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              material.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBadge(
                                  icon: Icons.style_rounded,
                                  text: '${material.chunks.length} Kartu Ide',
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  icon: Icons.timer_outlined,
                                  text: '±$estimateMinutes Menit',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Duration Selector Header
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Berapa Lama Ingin Fokus?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih durasi yang terasa nyaman tanpa membebani pikiranmu.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration Grid
                      Row(
                        children: durationOptions.map((opt) {
                          final minutes = opt['minutes'] as int;
                          final isSelected = focusState.durationMinutes == minutes;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () {
                                  ref.read(focusSessionProvider.notifier).setup(minutes);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF97316) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFFFEDD5),
                                      width: isSelected ? 2 : 1.2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFF97316).withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        opt['label'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt['desc'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // ADHD Gentle Tip Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🌱', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips Fokus ADHD',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF9A3412),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Baca kartu satu per satu dengan santai. Jika waktu habis, kamu akan dipandu untuk relaksasi sejenak!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4B5563),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(focusSessionProvider.notifier).start();
                  context.pushReplacement('/reader');
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(
                  isDone ? 'Pelajari Ulang Materi' : 'Mulai Sesi Membaca',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFEA580C)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
            ),
          ),
        ],
      ),
    );
  }
}
