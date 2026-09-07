import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AiService {
  static const String _envApiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _model = 'qwen/qwen3.6-27b'; 

  /// Resolves the API key from environment variables first, then local storage
  static Future<String> resolveApiKey() async {
    if (_envApiKey.isNotEmpty) {
      return _envApiKey;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('groq_api_key') ?? '';
  }

  /// Extracts text locally from supported files and sends to Groq
  Future<String> processMaterialFile(PlatformFile file) async {
    try {
      final apiKey = await resolveApiKey();
      if (apiKey.isEmpty) {
        throw Exception(
          'Groq API Key belum dikonfigurasi.\n\n'
          'Silakan isi API Key di file `env.json` atau atur langsung di menu Pengaturan aplikasi.',
        );
      }

      final bytes = await file.readAsBytes();

      String extractedText = '';

      // 1. Extract Text Locally
      if (file.extension == 'pdf') {
        extractedText = _extractPdfText(bytes);
      } else if (file.extension == 'txt' || file.extension == 'csv') {
        extractedText = utf8.decode(bytes);
      } else {
        throw Exception('Untuk Groq, saat ini hanya format PDF dan TXT yang didukung karena ekstraksi teks lokal.');
      }

      if (extractedText.trim().isEmpty) {
        throw Exception('Tidak ada teks yang dapat diekstrak dari file ini.');
      }

      // Clean excessive whitespace to save tokens
      extractedText = extractedText.replaceAll(RegExp(r'\s+'), ' ').trim();

      const int maxChars = 15000; 
      if (extractedText.length > maxChars) {
        debugPrint('Teks terlalu panjang (${extractedText.length} char). Memotong ke $maxChars karakter untuk menghindari Rate Limit.');
        extractedText = extractedText.substring(0, maxChars);
      }

      final prompt = '''
Anda adalah ahli aksesibilitas untuk anak-anak dengan ADHD dan Disleksia.
Ekstrak semua informasi penting dari teks berikut, lalu tulis ulang materi tersebut menjadi sangat mudah dibaca.
Aturan ketat:
1. Ekstrak ide utama.
2. Gunakan kalimat pendek, sederhana, dan bahasa Indonesia yang mudah dipahami.
3. Setiap unit konsep tidak boleh lebih dari 2 kalimat pendek.
4. Output harus berupa JSON Object dengan key "chunks" yang berisi array of strings. 
Contoh format wajib:
{
  "chunks": [
    "Kalimat pertama.",
    "Kalimat kedua yang mudah dipahami."
  ]
}

Teks sumber:
$extractedText
''';

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a JSON-only API. You must output only valid JSON. DO NOT output markdown formatting like ```json. DO NOT output any conversational text.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
          'max_tokens': 4000,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Groq API Error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      String content = data['choices'][0]['message']['content'] as String;
      
      // Clean up potential markdown formatting if the model ignored instructions
      content = content.trim();
      
      // Remove DeepSeek-R1 <think> blocks
      content = content.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '').trim();

      if (content.startsWith('```json')) {
        content = content.substring(7);
      } else if (content.startsWith('```')) {
        content = content.substring(3);
      }
      if (content.endsWith('```')) {
        content = content.substring(0, content.length - 3);
      }
      content = content.trim();

      // Fallback: If it still has junk text around it, try to extract the JSON object { ... }
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      if (match != null) {
        content = match.group(0)!;
      }

      final parsedJson = jsonDecode(content);
      
      List<dynamic> jsonArray;
      if (parsedJson is List) {
        jsonArray = parsedJson;
      } else if (parsedJson is Map) {
        // Find the first list value in the map
        final listValue = parsedJson.values.firstWhere((v) => v is List, orElse: () => []);
        jsonArray = listValue as List<dynamic>;
      } else {
        throw Exception('Invalid JSON structure from Groq');
      }

      return jsonArray.join('\n\n');

    } catch (e) {
      debugPrint('AI Processing Error: $e');
      throw Exception('Gagal memproses file: $e');
    }
  }

  String _extractPdfText(Uint8List bytes) {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      // Extract text
      final String text = PdfTextExtractor(document).extractText();
      // Dispose the document
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Gagal mengekstrak teks PDF: $e');
    }
  }
}
