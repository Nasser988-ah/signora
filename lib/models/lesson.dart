class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String youtubeUrl;
  final int durationMinutes;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.youtubeUrl,
    required this.durationMinutes,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      youtubeUrl: json['youtube_url'] as String,
      durationMinutes: json['duration_minutes'] as int,
      orderIndex: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
      'duration_minutes': durationMinutes,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Helper method to get YouTube video ID from URL
  String? get youtubeVideoId {
    final RegExp regExp = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})');
    final match = regExp.firstMatch(youtubeUrl);
    return match?.group(1);
  }

  // Helper method to get YouTube thumbnail URL
  String? get youtubeThumbnailUrl {
    final videoId = youtubeVideoId;
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return null;
  }

  // Helper method to get YouTube embed URL
  String? get youtubeEmbedUrl {
    final videoId = youtubeVideoId;
    if (videoId != null) {
      return 'https://www.youtube.com/embed/$videoId';
    }
    return null;
  }
}
