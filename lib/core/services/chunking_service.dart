import 'package:uuid/uuid.dart';
import '../../models/learning_chunk.dart';

class ChunkingService {
  final _uuid = const Uuid();

  List<LearningChunk> process(String text) {
    if (text.isEmpty) return [];

    final List<LearningChunk> chunks = [];
    
    // Split by paragraphs first
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    
    int order = 0;
    
    for (final p in paragraphs) {
      if (p.trim().isEmpty) continue;
      
      // Basic sentence splitting (simplified, looking for ., !, ?)
      // A more robust solution might use an NLP library, but for MVP we use regex.
      // Match punctuation followed by whitespace and an uppercase letter, or end of string.
      final matches = RegExp(r'[^.!?]+[.!?]+(?=\s+[A-Z]|\s*$)').allMatches(p);
      
      List<String> sentences = [];
      if (matches.isEmpty) {
        // Fallback if no punctuation found
        sentences.add(p.trim());
      } else {
        for (final m in matches) {
          sentences.add(m.group(0)!.trim());
        }
      }

      // Group into chunks of max 2 sentences
      for (int i = 0; i < sentences.length; i += 2) {
        String chunkContent = sentences[i];
        if (i + 1 < sentences.length) {
          chunkContent += ' ' + sentences[i + 1];
        }
        
        chunks.add(LearningChunk(
          id: _uuid.v4(),
          content: chunkContent,
          order: order++,
        ));
      }
    }

    return chunks;
  }
}
