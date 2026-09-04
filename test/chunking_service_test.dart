import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_belajar_adaptif/core/services/chunking_service.dart';

void main() {
  late ChunkingService chunker;

  setUp(() {
    chunker = ChunkingService();
  });

  test('splits text into chunks of max 2 sentences', () {
    final input = 'Sentence one. Sentence two. Sentence three. Sentence four. Sentence five.';
    final result = chunker.process(input);
    
    expect(result.length, 3);
    expect(result[0].content, 'Sentence one. Sentence two.');
    expect(result[1].content, 'Sentence three. Sentence four.');
    expect(result[2].content, 'Sentence five.');
  });

  test('handles paragraphs independently', () {
    final input = 'P1 S1. P1 S2. P1 S3.\n\nP2 S1. P2 S2.';
    final result = chunker.process(input);
    
    expect(result.length, 3);
    // Paragraph 1
    expect(result[0].content, 'P1 S1. P1 S2.');
    expect(result[1].content, 'P1 S3.');
    // Paragraph 2
    expect(result[2].content, 'P2 S1. P2 S2.');
  });

  test('handles text without punctuation safely', () {
    final input = 'This is just a long sentence without any punctuation';
    final result = chunker.process(input);
    
    expect(result.length, 1);
    expect(result[0].content, 'This is just a long sentence without any punctuation');
  });
}
