class LearningChunk {
  final String id;
  final String content;
  final int order;

  LearningChunk({
    required this.id,
    required this.content,
    required this.order,
  });

  factory LearningChunk.fromJson(Map<String, dynamic> json) {
    return LearningChunk(
      id: json['id'] as String,
      content: json['content'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'order': order,
    };
  }
}
