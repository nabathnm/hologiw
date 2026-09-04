import 'learning_chunk.dart';

class LearningMaterial {
  final String id;
  final String title;
  final String originalText;
  final List<LearningChunk> chunks;
  final int currentChunkIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningMaterial({
    required this.id,
    required this.title,
    required this.originalText,
    required this.chunks,
    this.currentChunkIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      originalText: json['originalText'] as String,
      chunks: (json['chunks'] as List<dynamic>)
          .map((e) => LearningChunk.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentChunkIndex: json['currentChunkIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalText': originalText,
      'chunks': chunks.map((e) => e.toJson()).toList(),
      'currentChunkIndex': currentChunkIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LearningMaterial copyWith({
    String? id,
    String? title,
    String? originalText,
    List<LearningChunk>? chunks,
    int? currentChunkIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningMaterial(
      id: id ?? this.id,
      title: title ?? this.title,
      originalText: originalText ?? this.originalText,
      chunks: chunks ?? this.chunks,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
