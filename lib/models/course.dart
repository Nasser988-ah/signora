class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final double price;
  final double rating;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String>? pdfUrls;
  final List<String>? audioUrls;
  final int durationMinutes;
  final String category;
  final String difficultyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? enrolledStudents;
  final int? duration; // Duration in hours
  final List<dynamic>? lessons;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.price,
    required this.rating,
    this.thumbnailUrl,
    this.videoUrl,
    this.pdfUrls,
    this.audioUrls,
    required this.durationMinutes,
    required this.category,
    required this.difficultyLevel,
    required this.createdAt,
    required this.updatedAt,
    this.enrolledStudents,
    this.duration,
    this.lessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructorId: json['instructor_id'] as String,
      instructorName: json['instructor_name'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      pdfUrls: json['pdf_urls'] != null ? List<String>.from(json['pdf_urls']) : null,
      audioUrls: json['audio_urls'] != null ? List<String>.from(json['audio_urls']) : null,
      durationMinutes: json['duration_minutes'] as int,
      category: json['category'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      enrolledStudents: json['enrolled_students'] as int?,
      duration: json['duration'] as int?,
      lessons: json['lessons'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'price': price,
      'rating': rating,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'pdf_urls': pdfUrls,
      'audio_urls': audioUrls,
      'duration_minutes': durationMinutes,
      'category': category,
      'difficulty_level': difficultyLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'enrolled_students': enrolledStudents,
      'duration': duration,
      'lessons': lessons,
    };
  }

  // Helper methods
  String get formattedPrice => price == 0 ? 'Free' : '£E ${price.toStringAsFixed(0)}';
  String get formattedDuration => '${durationMinutes ~/ 60}h ${durationMinutes % 60}m';
  String get formattedRating => rating.toStringAsFixed(1);
  String get instructor => instructorName; // Alias for backward compatibility
}
