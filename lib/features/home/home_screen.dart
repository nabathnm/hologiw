import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/materials_provider.dart';
import '../../models/learning_material.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(materialsProvider);

    final completedCount = materials.where((m) => m.chunks.isNotEmpty && m.currentChunkIndex >= m.chunks.length).length;
    final inProgressCount = materials.where((m) => m.chunks.isNotEmpty && m.currentChunkIndex < m.chunks.length && m.currentChunkIndex > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruang Belajarmu 🌟'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: Color(0xFFEA580C)),
              onPressed: () => context.push('/personalization'),
              tooltip: 'Pengaturan Tampilan',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: materials.isEmpty
            ? _buildEmptyState(context)
            : CustomScrollView(
                slivers: [
                  // Motivational Banner & Stats Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fokus Tanpa Batas!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: Color(0xFF9A3412),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Satu ide per layar untuk belajar lebih tenang.',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Quick Stats Row
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'Total Materi',
                                value: '${materials.length}',
                                icon: Icons.library_books_rounded,
                                color: const Color(0xFFF97316),
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                label: 'Sedang Dibaca',
                                value: '$inProgressCount',
                                icon: Icons.hourglass_top_rounded,
                                color: const Color(0xFFEA580C),
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                label: 'Selesai',
                                value: '$completedCount',
                                icon: Icons.verified_rounded,
                                color: const Color(0xFF16A34A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Daftar Materi Belajar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Material List
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sortedMaterials = List<LearningMaterial>.from(materials)
                            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                          final material = sortedMaterials[index];
                          return _buildMaterialCard(context, ref, material);
                        },
                        childCount: materials.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/import'),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Tambah Materi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFEDD5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, WidgetRef ref, LearningMaterial material) {
    final totalChunks = material.chunks.length;
    final progress = totalChunks == 0 ? 0.0 : material.currentChunkIndex / totalChunks;
    final percent = (progress * 100).toInt();
    final isDone = totalChunks > 0 && material.currentChunkIndex >= totalChunks;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDone ? const Color(0xFFBBF7D0) : const Color(0xFFFFEDD5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ref.read(currentMaterialIdProvider.notifier).state = material.id;
          context.push('/focus-setup');
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.style_rounded, size: 14, color: Color(0xFFEA580C)),
                        const SizedBox(width: 5),
                        Text(
                          '$totalChunks Kartu Ide',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9A3412),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDone ? '✓ Selesai' : '$percent% selesai',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDone ? const Color(0xFF15803D) : const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Material Title
              Text(
                material.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFFFEDD5),
                  color: isDone ? const Color(0xFF16A34A) : const Color(0xFFF97316),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              // Card Footer Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kartu ${material.currentChunkIndex} dari $totalChunks',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDone ? 'Ulangi Belajar' : 'Lanjutkan',
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFFEA580C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.menu_book_rounded, size: 52, color: Color(0xFFEA580C)),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Belum Ada Materi Belajar',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unggah dokumen PDF atau teks pelajaranmu.\nAI kami akan membaginya menjadi kartu-kartu kecil yang mudah dipahami tanpa bikin lelah!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF4B5563), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/import'),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Unggah Materi Pertama'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
