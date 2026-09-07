class TextCleanerService {
  String clean(String input) {
    if (input.isEmpty) return '';

    // Remove HTML tags (simple approach)
    String text = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove markdown bold/italic
    text = text.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (match) => match.group(1)!);
    text = text.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (match) => match.group(1)!);
    text = text.replaceAllMapped(RegExp(r'__([^_]+)__'), (match) => match.group(1)!);
    text = text.replaceAllMapped(RegExp(r'_([^_]+)_'), (match) => match.group(1)!);

    // Remove repeated whitespace
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

    // Normalize newlines (more than 2 to just 2)
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Trim lines
    final lines = text.split('\n').map((l) => l.trim()).toList();
    text = lines.join('\n');

    return text.trim();
  }
}
