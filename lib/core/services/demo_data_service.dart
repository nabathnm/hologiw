import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/materials_provider.dart';
import '../../core/services/storage_service.dart';
import '../../providers/storage_provider.dart';

class DemoDataService {
  static Future<void> loadDemoData(ProviderContainer container) async {
    final storage = container.read(storageServiceProvider);
    final materials = storage.getMaterials();
    
    // Only load demo data if no materials exist
    if (materials.isEmpty) {
      final materialsNotifier = container.read(materialsProvider.notifier);
      
      await materialsNotifier.addMaterial(
        'Fotosintesis',
        'Fotosintesis adalah proses tumbuhan membuat makanan.\n\nProses ini membutuhkan cahaya matahari, air, dan karbon dioksida.\n\nFotosintesis terutama terjadi pada daun.\n\nKlorofil membantu menangkap energi cahaya matahari.',
      );

      await materialsNotifier.addMaterial(
        'Sistem Tata Surya',
        'Tata surya kita terdiri dari matahari dan benda-benda langit yang mengelilinginya.\n\nMatahari adalah pusat dari tata surya kita.\n\nAda delapan planet yang mengelilingi matahari.\n\nBumi adalah planet ketiga dari matahari dan satu-satunya yang diketahui memiliki kehidupan.',
      );

      await materialsNotifier.addMaterial(
        'Bangun Ruang',
        'Bangun ruang adalah bangun tiga dimensi yang memiliki volume atau isi.\n\nContoh bangun ruang adalah kubus, balok, bola, dan tabung.\n\nKubus memiliki enam sisi yang berbentuk persegi dengan ukuran sama.\n\nBalok memiliki enam sisi yang berbentuk persegi panjang.',
      );
    }
  }
}
