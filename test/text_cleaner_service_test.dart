import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_belajar_adaptif/core/services/text_cleaner_service.dart';

void main() {
  late TextCleanerService cleaner;

  setUp(() {
    cleaner = TextCleanerService();
  });

  test('removes markdown formatting', () {
    final input = '**Bold** and *italic* and __underline__';
    final result = cleaner.clean(input);
    expect(result, 'Bold and italic and underline');
  });

  test('removes HTML tags', () {
    final input = '<p>This is a <b>test</b>.</p>';
    final result = cleaner.clean(input);
    expect(result, 'This is a test.');
  });

  test('normalizes excessive newlines', () {
    final input = 'Line 1\n\n\n\nLine 2';
    final result = cleaner.clean(input);
    expect(result, 'Line 1\n\nLine 2');
  });

  test('removes extra whitespace', () {
    final input = 'This   has   extra    spaces.';
    final result = cleaner.clean(input);
    expect(result, 'This has extra spaces.');
  });
}
