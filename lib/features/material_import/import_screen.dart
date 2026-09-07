import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/materials_provider.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _titleController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'ppt', 'pptx', 'txt'],
      // withData is no longer needed since we read it explicitly in the service, but if it exists we can keep it or remove it. We'll just remove `withData: true,` as it might be removed in v12.
    );

    if (result.isNotEmpty) {
      setState(() {
        _selectedFile = result.first;
        // Optionally set title from filename if empty
        if (_titleController.text.isEmpty) {
          _titleController.text = _selectedFile!.name.split('.').first;
        }
      });
    }
  }

  void _processMaterial() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan file dokumen tidak boleh kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(materialsProvider.notifier).addMaterialFromFile(title, _selectedFile!);
      if (mounted) {
        context.pop(); // Return to home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Materi Baru'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Materi Pelajaran',
                  hintText: 'Contoh: Biologi - Fotosintesis',
                  prefixIcon: Icon(Icons.bookmark_outline_rounded, color: Color(0xFFEA580C)),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Upload Dropzone Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _selectedFile != null ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedFile != null ? Colors.green : const Color(0xFFF97316)).withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _selectedFile != null ? Icons.task_alt_rounded : Icons.cloud_upload_rounded,
                            size: 38,
                            color: _selectedFile != null ? const Color(0xFF15803D) : const Color(0xFFEA580C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _selectedFile != null ? _selectedFile!.name : 'Pilih File Dokumen',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _selectedFile != null ? const Color(0xFF15803D) : const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (_selectedFile == null) ...[
                        const Text(
                          'Mendukung format dokumen pelajaran:',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFormatChip('PDF'),
                            const SizedBox(width: 8),
                            _buildFormatChip('TXT'),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'File siap diproses oleh AI',
                          style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                        ),
                      ],
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickFile,
                        icon: Icon(_selectedFile != null ? Icons.cached_rounded : Icons.folder_open_rounded),
                        label: Text(_selectedFile != null ? 'Ganti File' : 'Jelajahi File'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // AI Helper Tip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: const Row(
                  children: [
                    Text('✨', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI akan meringkas dan membagi teks menjadi kartu-kartu kecil agar tidak membuat lelah fokusmu.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _processMaterial,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_isLoading ? 'AI Sedang Menyesuaikan Materi...' : 'Proses Materi dengan AI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9A3412),
        ),
      ),
    );
  }
}
