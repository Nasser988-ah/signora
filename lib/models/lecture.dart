class Lecture {
  final String id;
  final String title;
  final String subtitle;
  final String instructor;
  final String startTime;
  final String endTime;
  final int duration; // in minutes
  final String description;
  final bool hasNotification;

  const Lecture({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.description,
    required this.hasNotification,
  });

  // Helper method to get formatted time range
  String get timeRange => '$startTime - $endTime';

  // Helper method to get formatted duration
  String get formattedDuration => '$duration minutes';
}
