class YouTubeValidator {
  // Regular expressions for different YouTube URL formats
  static final List<RegExp> _youtubePatterns = [
    // Standard YouTube URLs
    RegExp(r'^https?:\/\/(www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]{11})'),
    // YouTube short URLs
    RegExp(r'^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]{11})'),
    // YouTube embed URLs
    RegExp(r'^https?:\/\/(www\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
    // YouTube mobile URLs
    RegExp(r'^https?:\/\/m\.youtube\.com\/watch\?v=([a-zA-Z0-9_-]{11})'),
  ];

  /// Validates if a URL is a valid YouTube URL
  static bool isValidYouTubeUrl(String url) {
    if (url.trim().isEmpty) return false;
    
    for (final pattern in _youtubePatterns) {
      if (pattern.hasMatch(url)) {
        return true;
      }
    }
    return false;
  }

  /// Extracts YouTube video ID from various URL formats
  static String? extractVideoId(String url) {
    if (url.trim().isEmpty) return null;
    
    for (final pattern in _youtubePatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(match.groupCount); // Get the last captured group (video ID)
      }
    }
    return null;
  }

  /// Converts any YouTube URL to a standard watch URL
  static String? normalizeYouTubeUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId != null) {
      return 'https://www.youtube.com/watch?v=$videoId';
    }
    return null;
  }

  /// Gets YouTube thumbnail URL from video ID
  static String getThumbnailUrl(String videoId, {String quality = 'maxresdefault'}) {
    // Available qualities: maxresdefault, sddefault, hqdefault, mqdefault, default
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  /// Gets YouTube embed URL from video ID
  static String getEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId';
  }

  /// Validates and provides user-friendly error messages
  static String? validateYouTubeUrl(String url) {
    if (url.trim().isEmpty) {
      return 'Please enter a YouTube URL';
    }

    if (!url.toLowerCase().contains('youtube.com') && !url.toLowerCase().contains('youtu.be')) {
      return 'Please enter a valid YouTube URL';
    }

    if (!isValidYouTubeUrl(url)) {
      return 'Invalid YouTube URL format. Please use a standard YouTube link';
    }

    return null; // Valid URL
  }

  /// Example valid URLs for user reference
  static List<String> get exampleUrls => [
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'https://youtu.be/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
  ];
}
