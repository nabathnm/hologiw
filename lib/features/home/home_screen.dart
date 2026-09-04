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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selamat belajar 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/personalization'),
            tooltip: 'Pengaturan',
          )
        ],
      ),
      body: SafeArea(
        child: materials.isEmpty
            ? _buildEmptyState(context)
            : _buildMaterialList(context, ref, materials),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/import'),
        icon: const Icon(Icons.add),
        label: const Text('Tambahkan Materi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64, color: Colors.black26),
            const SizedBox(height: 24),
            const Text(
              'Belum ada materi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tambahkan materi pertamamu\ndan mulai belajar dengan\ncara yang lebih nyaman.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(BuildContext context, WidgetRef ref, List<LearningMaterial> materials) {
    // Sort by recently updated
    final sortedMaterials = List<LearningMaterial>.from(materials)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16), // space for FAB
      itemCount: sortedMaterials.length,
      itemBuilder: (context, index) {
        final material = sortedMaterials[index];
        final progress = material.chunks.isEmpty ? 0.0 : material.currentChunkIndex / material.chunks.length;
        final percent = (progress * 100).toInt();

        return Card(
          child: InkWell(
            onTap: () {
              ref.read(currentMaterialIdProvider.notifier).state = material.id;
              context.push('/focus-setup');
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${material.chunks.length} kartu • $percent% selesai',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black12,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      progress >= 1.0 ? 'Baca Lagi' : 'Lanjutkan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
