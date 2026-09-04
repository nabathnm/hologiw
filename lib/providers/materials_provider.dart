import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_material.dart';
import '../core/services/text_cleaner_service.dart';
import '../core/services/chunking_service.dart';
import 'storage_provider.dart';

final textCleanerProvider = Provider<TextCleanerService>((ref) => TextCleanerService());
final chunkingProvider = Provider<ChunkingService>((ref) => ChunkingService());

class MaterialsNotifier extends Notifier<List<LearningMaterial>> {
  @override
  List<LearningMaterial> build() {
    return ref.watch(storageServiceProvider).getMaterials();
  }

  Future<void> addMaterial(String title, String text) async {
    final cleaner = ref.read(textCleanerProvider);
    final chunker = ref.read(chunkingProvider);

    final cleanedText = cleaner.clean(text);
    final chunks = chunker.process(cleanedText);

    if (chunks.isEmpty) {
      throw Exception('Materi terlalu pendek untuk diproses.');
    }

    final newMaterial = LearningMaterial(
      id: const Uuid().v4(),
      title: title,
      originalText: cleanedText,
      chunks: chunks,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = [...state, newMaterial];
    await _save();
  }

  Future<void> updateProgress(String materialId, int chunkIndex) async {
    state = [
      for (final material in state)
        if (material.id == materialId)
          material.copyWith(
            currentChunkIndex: chunkIndex,
            updatedAt: DateTime.now(),
          )
        else
          material
    ];
    await _save();
  }

  Future<void> _save() async {
    await ref.read(storageServiceProvider).saveMaterials(state);
  }
}

final materialsProvider = NotifierProvider<MaterialsNotifier, List<LearningMaterial>>(() {
  return MaterialsNotifier();
});

class CurrentMaterialIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
}

final currentMaterialIdProvider = NotifierProvider<CurrentMaterialIdNotifier, String?>(() {
  return CurrentMaterialIdNotifier();
});

final currentMaterialProvider = Provider<LearningMaterial?>((ref) {
  final materials = ref.watch(materialsProvider);
  final currentId = ref.watch(currentMaterialIdProvider);
  
  if (currentId == null) return null;
  
  try {
    return materials.firstWhere((m) => m.id == currentId);
  } catch (e) {
    return null;
  }
});
