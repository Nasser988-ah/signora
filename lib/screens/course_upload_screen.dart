import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../services/background_upload_service.dart';
import '../models/course.dart';
import '../models/lesson_upload.dart';
import '../screens/youtube_lesson_dialog.dart';

class CourseUploadScreen extends StatefulWidget {
  const CourseUploadScreen({super.key});

  @override
  State<CourseUploadScreen> createState() => _CourseUploadScreenState();
}

class _CourseUploadScreenState extends State<CourseUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = 'Programming';
  String _selectedDifficulty = 'Beginner';
  File? _thumbnailFile;
  List<LessonUpload> _lessons = [];
  List<File> _pdfFiles = [];
  List<File> _audioFiles = [];
  bool _isUploading = false;
  bool _isBackgroundUploading = false;
  int _uploadProgress = 0;
  String _uploadStatus = '';
  StreamSubscription<UploadProgress>? _progressSubscription;

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

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _progressSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addLesson() async {
    final result = await showDialog<LessonUpload>(
      context: context,
      builder: (context) => YouTubeLessonDialog(
        orderIndex: _lessons.length + 1,
      ),
    );

    if (result != null) {
      setState(() {
        _lessons.add(result);
      });
    }
  }

  Future<void> _editLesson(int index) async {
    final result = await showDialog<LessonUpload>(
      context: context,
      builder: (context) => YouTubeLessonDialog(
        existingLesson: _lessons[index],
        orderIndex: index + 1,
      ),
    );

    if (result != null) {
      setState(() {
        _lessons[index] = result;
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _pdfFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  Future<void> _pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _audioFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  Future<void> _uploadCourse() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course thumbnail'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one lesson'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show dialog asking user if they want background upload
    final useBackgroundUpload = await _showBackgroundUploadDialog();
    
    if (useBackgroundUpload) {
      await _startBackgroundUpload();
    } else {
      await _startForegroundUpload();
    }
  }

  Future<bool> _showBackgroundUploadDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Upload Method',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Large courses may take time to upload. Choose your preferred method:',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Upload Now',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B6FEE),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Background Upload',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _startBackgroundUpload() async {
    try {
      setState(() {
        _isBackgroundUploading = true;
        _uploadProgress = 0;
        _uploadStatus = 'Starting upload...';
      });
      
      // Listen to progress updates
      _progressSubscription = BackgroundUploadService.progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _uploadProgress = progress.progress;
            _uploadStatus = progress.status;
            if (progress.isComplete) {
              _isBackgroundUploading = false;
            }
          });
        }
      });

      // Prepare lesson data for background upload
      final List<Map<String, dynamic>> lessonsData = _lessons.map((lesson) {
        return {
          'title': lesson.title,
          'description': lesson.description,
          'youtubeUrl': lesson.youtubeUrl,
          'orderIndex': lesson.orderIndex,
          'durationMinutes': lesson.durationMinutes,
        };
      }).toList();

      // Start background upload
      await BackgroundUploadService.startCourseUpload(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        category: _selectedCategory,
        difficultyLevel: _selectedDifficulty,
        thumbnailPath: _thumbnailFile!.path,
        lessonsData: lessonsData,
        pdfPaths: _pdfFiles.map((file) => file.path).toList(),
        audioPaths: _audioFiles.map((file) => file.path).toList(),
      );

    } catch (e) {
      if (mounted) {
        setState(() {
          _isBackgroundUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start background upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startForegroundUpload() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final course = await SupabaseService.uploadCourseWithLessons(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        category: _selectedCategory,
        difficultyLevel: _selectedDifficulty,
        thumbnailFile: _thumbnailFile!,
        lessons: _lessons,
        pdfFiles: _pdfFiles,
        audioFiles: _audioFiles,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course "${course.title}" uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Course',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_isUploading || _isBackgroundUploading) ? null : _uploadCourse,
            child: (_isUploading || _isBackgroundUploading)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Upload',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 16,
                ).copyWith(
                  bottom: _isBackgroundUploading ? 140 : 16, // Add bottom padding when progress bar is shown
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Course Title
              _buildSectionTitle('Course Title'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: 'Enter course title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Course Description
              _buildSectionTitle('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Describe what students will learn...',
                maxLines: 4,
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
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Category'),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              value: _selectedCategory,
                              items: _categories,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Difficulty'),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              value: _selectedDifficulty,
                              items: _difficulties,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDifficulty = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Price Row
              _buildSectionTitle('Price (£E)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _priceController,
                hintText: '0 for free',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Thumbnail Upload
              _buildSectionTitle('Course Thumbnail *'),
              const SizedBox(height: 8),
              _buildThumbnailUpload(),
              const SizedBox(height: 24),

              // Lessons Section
              _buildLessonsSection(),
              const SizedBox(height: 24),

              // Additional Materials
              _buildAdditionalMaterials(),
              
              const SizedBox(height: 32),
              
              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isUploading || _isBackgroundUploading) ? null : _uploadCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B6FEE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Uploading Course...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Upload Course',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              ],
                ),
              ),
            ),
          ),
          // Bottom progress bar overlay
          if (_isBackgroundUploading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomProgressBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hintText,
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.inter(
          fontSize: 16,
          color: const Color(0xFF1F2937),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThumbnailUpload() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _thumbnailFile != null ? const Color(0xFF5B6FEE) : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: _thumbnailFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _thumbnailFile!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B6FEE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: Color(0xFF5B6FEE),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Thumbnail',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended: 1920x1080 (16:9)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Lessons (${_lessons.length}) *',
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
                  'Add YouTube video lessons to your course',
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lesson.formattedDuration,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.link,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'YouTube Video',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (lesson.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editLesson(index),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ),
              IconButton(
                onPressed: () => _removeLesson(index),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
              ),
            ],
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
        
        // PDF Files
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

  Widget _buildBottomProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _uploadProgress >= 100 ? Icons.check_circle : Icons.cloud_upload,
                  color: _uploadProgress >= 100 ? const Color(0xFF10B981) : const Color(0xFF5B6FEE),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _uploadProgress >= 100 ? 'Upload Complete!' : 'Uploading Course...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _uploadProgress >= 100 ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (_uploadProgress < 100)
                  GestureDetector(
                    onTap: _cancelUpload,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _uploadStatus,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_uploadProgress.toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B6FEE),
                      ),
                    ),
                    Text(
                      _uploadProgress >= 100 ? 'Complete' : 'In Progress',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _uploadProgress >= 100 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _uploadProgress / 100,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _uploadProgress >= 100 ? const Color(0xFF10B981) : const Color(0xFF5B6FEE)
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _uploadProgress >= 100 ? Icons.check : Icons.info_outline,
                  size: 16,
                  color: _uploadProgress >= 100 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _uploadProgress >= 100 
                        ? 'Course uploaded successfully! You can now close this screen.'
                        : 'Upload continues in background. You\'ll get notified when complete.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _uploadProgress >= 100 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
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

  void _cancelUpload() {
    setState(() {
      _isBackgroundUploading = false;
      _uploadProgress = 0;
      _uploadStatus = 'Upload cancelled';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload cancelled'),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}
