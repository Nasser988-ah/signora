class LessonUpload {
  final String title;
  final String? description;
  final String youtubeUrl;
  final int orderIndex;
  final int durationMinutes;

  LessonUpload({
    required this.title,
    this.description,
    required this.youtubeUrl,
    required this.orderIndex,
    this.durationMinutes = 0,
  });

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

  // Helper method to validate YouTube URL
  bool get isValidYouTubeUrl {
    return youtubeVideoId != null;
  }

  // Helper method to get formatted duration
  String get formattedDuration {
    if (durationMinutes <= 0) return 'Duration not set';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
