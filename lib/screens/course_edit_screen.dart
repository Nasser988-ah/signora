import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/course.dart';
import '../models/lesson_upload.dart';
import '../services/supabase_service.dart';
import '../services/file_upload_service.dart';
import 'lesson_upload_dialog.dart';

class CourseEditScreen extends StatefulWidget {
  final Course course;

  const CourseEditScreen({super.key, required this.course});

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'Programming';
  String _selectedDifficulty = 'Beginner';
  File? _thumbnailFile;
  List<File> _pdfFiles = [];
  List<File> _audioFiles = [];
  List<LessonUpload> _lessons = [];
  bool _isLoading = false;
  bool _isUploadingFiles = false;

  final List<String> _categories = [
    'Programming',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Health & Fitness',
    'Language',
    'Other'
  ];

  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.course.title;
    _descriptionController.text = widget.course.description;
    _priceController.text = widget.course.price.toString();
    _durationController.text = widget.course.durationMinutes.toString();
    _selectedCategory = widget.course.category;
    _selectedDifficulty = widget.course.difficultyLevel;
    
    // Load existing lessons if any
    if (widget.course.lessons != null && widget.course.lessons!.isNotEmpty) {
      _lessons = widget.course.lessons!.asMap().entries.map((entry) {
        final index = entry.key;
        final lesson = entry.value;
        return LessonUpload(
          title: lesson['title'] ?? 'Lesson',
          description: lesson['description'] ?? '',
          youtubeUrl: lesson['youtube_url'] ?? '',
          orderIndex: index + 1,
          durationMinutes: lesson['duration_minutes'] ?? 0,
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _thumbnailFile = File(image.path);
      });
    }
  }

  Future<void> _addLesson() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LessonUploadDialog(),
    );
    
    if (result != null) {
      setState(() {
        _lessons.add(LessonUpload(
          title: result['title'],
          description: result['description'],
          youtubeUrl: result['youtubeUrl'] ?? '',
          orderIndex: _lessons.length + 1,
          durationMinutes: result['durationMinutes'] ?? 0,
        ));
      });
    }
  }

  void _removeLesson(int index) {
    setState(() {
      _lessons.removeAt(index);
      // Update order indices
      for (int i = 0; i < _lessons.length; i++) {
        _lessons[i] = LessonUpload(
          title: _lessons[i].title,
          description: _lessons[i].description,
          youtubeUrl: _lessons[i].youtubeUrl,
          orderIndex: i + 1,
          durationMinutes: _lessons[i].durationMinutes,
        );
      }
    });
  }

  Future<void> _pickPdfFiles() async {
    try {
      final files = await FileUploadService.pickPdfFiles();
      if (files != null) {
        setState(() {
          _pdfFiles.addAll(files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking PDF files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAudioFiles() async {
    try {
      final files = await FileUploadService.pickAudioFiles();
      if (files != null) {
        setState(() {
          _audioFiles.addAll(files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking audio files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePdfFile(int index) {
    setState(() {
      _pdfFiles.removeAt(index);
    });
  }

  void _removeAudioFile(int index) {
    setState(() {
      _audioFiles.removeAt(index);
    });
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isUploadingFiles = true;
    });

    try {
      List<String>? pdfUrls;
      List<String>? audioUrls;

      // Upload PDF files if any
      if (_pdfFiles.isNotEmpty) {
        pdfUrls = await FileUploadService.uploadPdfFiles(_pdfFiles, widget.course.id);
      }

      // Upload audio files if any
      if (_audioFiles.isNotEmpty) {
        audioUrls = await FileUploadService.uploadAudioFiles(_audioFiles, widget.course.id);
      }

      setState(() {
        _isUploadingFiles = false;
      });

      // Debug: Print lessons before update
      print('Updating course with ${_lessons.length} lessons');
      for (int i = 0; i < _lessons.length; i++) {
        print('Lesson $i: ${_lessons[i].title}, youtubeUrl: ${_lessons[i].youtubeUrl}');
      }

      await SupabaseService.updateCourse(
        courseId: widget.course.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationMinutes: int.parse(_durationController.text.trim()),
        category: _selectedCategory,
        difficultyLevel: _selectedDifficulty,
        thumbnailFile: _thumbnailFile,
        videoFile: null,
        pdfUrls: pdfUrls,
        audioUrls: audioUrls,
        lessons: _lessons,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Course updated successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating course: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingFiles = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Course',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _updateCourse,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF5B6FEE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Update',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Title
              Text(
                'Course Title',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter course title',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5B6FEE)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter course description',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5B6FEE)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Category and Difficulty Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: (constraints.maxWidth - 16) / 2,
                          maxWidth: constraints.maxWidth > 400 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: (constraints.maxWidth - 16) / 2,
                          maxWidth: constraints.maxWidth > 400 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Difficulty',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedDifficulty,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                ),
                                items: _difficulties.map((difficulty) {
                                  return DropdownMenuItem(
                                    value: difficulty,
                                    child: Text(difficulty),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDifficulty = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ), const SizedBox(height: 24),

              // Price and Duration Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: (constraints.maxWidth - 16) / 2,
                          maxWidth: constraints.maxWidth > 400 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price (£)',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF1F2937),
                              ),
                              decoration: InputDecoration(
                                hintText: '0 for free',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF5B6FEE), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: (constraints.maxWidth - 16) / 2,
                          maxWidth: constraints.maxWidth > 400 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration (minutes)',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF1F2937),
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. 120',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF5B6FEE), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Course Thumbnail
              Text(
                'Course Thumbnail',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _thumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _thumbnailFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : widget.course.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.course.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildThumbnailPlaceholder();
                                },
                              ),
                            )
                          : _buildThumbnailPlaceholder(),
                ),
              ),
              if (_thumbnailFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'New thumbnail selected',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF5B6FEE),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Course Lessons
              Text(
                'Course Lessons',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              _buildLessonsSection(),

              const SizedBox(height: 24),

              // Additional Materials
              _buildAdditionalMaterials(),

              const SizedBox(height: 24),

              // PDF Files Section
              Text(
                'PDF Materials',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickPdfFiles,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: const Color(0xFF5B6FEE),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add PDF Files',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF5B6FEE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.add,
                            color: const Color(0xFF5B6FEE),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    // PDF Files List
                    if (_pdfFiles.isNotEmpty)
                      Column(
                        children: _pdfFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FileUploadService.getFileName(file.path),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        FileUploadService.getFileSizeString(file),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removePdfFile(index),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade600,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Audio Files Section
              Text(
                'Audio Materials',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Add Audio Button
                    GestureDetector(
                      onTap: _pickAudioFiles,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.audiotrack,
                              color: const Color(0xFF5B6FEE),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add Audio Files',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5B6FEE),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.add,
                              color: const Color(0xFF5B6FEE),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Audio Files List
                    if (_audioFiles.isNotEmpty)
                      Column(
                        children: _audioFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.audiotrack,
                                  color: const Color(0xFF5B6FEE),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FileUploadService.getFileName(file.path),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        FileUploadService.getFileSizeString(file),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeAudioFile(index),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade600,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // Upload Progress Indicator
              if (_isUploadingFiles)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6FEE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6FEE)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Uploading files to Supabase...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5B6FEE),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B6FEE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Update Course',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Lessons (${_lessons.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addLesson,
              icon: const Icon(Icons.add, size: 18, color: Color(0xFF5B6FEE)),
              label: Text(
                'Add Lesson',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5B6FEE),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_lessons.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No lessons added yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add video lessons to your course',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_lessons.length, (index) => _buildLessonCard(index)),
      ],
    );
  }

  Widget _buildLessonCard(int index) {
    final lesson = _lessons[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5B6FEE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 20,
              color: Color(0xFF5B6FEE),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeLesson(index),
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalMaterials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Materials (Optional)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // PDF and Audio Files Row
        Row(
          children: [
            Expanded(
              child: _buildMaterialCard(
                title: 'PDF Files',
                count: _pdfFiles.length,
                icon: Icons.picture_as_pdf,
                onTap: _pickPdfFiles,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMaterialCard(
                title: 'Audio Files',
                count: _audioFiles.length,
                icon: Icons.audiotrack,
                onTap: _pickAudioFiles,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialCard({
    required String title,
    required int count,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: count > 0 ? color : const Color(0xFFE5E7EB),
            width: count > 0 ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: count > 0 ? color : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: count > 0 ? color : const Color(0xFF6B7280),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 2),
              Text(
                '$count file${count == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to select thumbnail',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
