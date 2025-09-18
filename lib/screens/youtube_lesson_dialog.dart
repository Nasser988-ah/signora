import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson_upload.dart';
import '../utils/youtube_validator.dart';

class YouTubeLessonDialog extends StatefulWidget {
  final LessonUpload? existingLesson;
  final int orderIndex;

  const YouTubeLessonDialog({
    super.key,
    this.existingLesson,
    required this.orderIndex,
  });

  @override
  State<YouTubeLessonDialog> createState() => _YouTubeLessonDialogState();
}

class _YouTubeLessonDialogState extends State<YouTubeLessonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _durationController = TextEditingController();
  
  bool _isValidatingUrl = false;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingLesson != null) {
      _titleController.text = widget.existingLesson!.title;
      _descriptionController.text = widget.existingLesson!.description ?? '';
      _youtubeUrlController.text = widget.existingLesson!.youtubeUrl;
      _durationController.text = widget.existingLesson!.durationMinutes.toString();
      _thumbnailUrl = widget.existingLesson!.youtubeThumbnailUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _validateYouTubeUrl() {
    final url = _youtubeUrlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _thumbnailUrl = null;
      });
      return;
    }

    setState(() {
      _isValidatingUrl = true;
    });

    final videoId = YouTubeValidator.extractVideoId(url);
    if (videoId != null) {
      setState(() {
        _thumbnailUrl = YouTubeValidator.getThumbnailUrl(videoId);
        _isValidatingUrl = false;
      });
    } else {
      setState(() {
        _thumbnailUrl = null;
        _isValidatingUrl = false;
      });
    }
  }

  void _saveLesson() {
    if (_formKey.currentState!.validate()) {
      final lesson = LessonUpload(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        youtubeUrl: YouTubeValidator.normalizeYouTubeUrl(_youtubeUrlController.text.trim()) 
            ?? _youtubeUrlController.text.trim(),
        orderIndex: widget.orderIndex,
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
      );
      
      Navigator.of(context).pop(lesson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: const Color(0xFF3B82F6),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.existingLesson != null ? 'Edit Lesson' : 'Add New Lesson',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lesson Title
                      Text(
                        'Lesson Title',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter lesson title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a lesson title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // YouTube URL
                      Text(
                        'YouTube URL',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _youtubeUrlController,
                        decoration: InputDecoration(
                          hintText: 'https://www.youtube.com/watch?v=...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          suffixIcon: _isValidatingUrl
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _validateYouTubeUrl,
                                  icon: const Icon(Icons.search),
                                  color: const Color(0xFF6B7280),
                                ),
                        ),
                        onChanged: (value) {
                          // Auto-validate as user types
                          if (value.contains('youtube.com') || value.contains('youtu.be')) {
                            _validateYouTubeUrl();
                          }
                        },
                        validator: (value) => YouTubeValidator.validateYouTubeUrl(value ?? ''),
                      ),
                      const SizedBox(height: 12),

                      // YouTube Thumbnail Preview
                      if (_thumbnailUrl != null) ...[
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Color(0xFF6B7280),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Duration
                      Text(
                        'Duration (minutes)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter duration in minutes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter lesson duration';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Please enter a valid duration';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description (Optional)
                      Text(
                        'Description (Optional)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter lesson description...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.existingLesson != null ? 'Update Lesson' : 'Add Lesson',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
