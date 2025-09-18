import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../models/lesson_upload.dart';

class CourseUploadEnhancedScreen extends StatefulWidget {
  const CourseUploadEnhancedScreen({Key? key}) : super(key: key);

  @override
  State<CourseUploadEnhancedScreen> createState() => _CourseUploadEnhancedScreenState();
}

class _CourseUploadEnhancedScreenState extends State<CourseUploadEnhancedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _thumbnailFile;
  List<LessonUpload> _lessons = [];
  bool _isUploading = false;
  String _selectedCategory = 'Programming';
  String _selectedDifficulty = 'Beginner';
  
  final List<String> _categories = [
    'Programming',
    'Data Science',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Language',
    'Other'
  ];
  
  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Course Basic Info Section
                  _buildSectionCard(
                    'Course Information',
                    Icons.school_outlined,
                    [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Course Title',
                        hint: 'Enter course title',
                        validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your course',
                        maxLines: 4,
                        validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Category',
                              value: _selectedCategory,
                              items: _categories,
                              onChanged: (value) => setState(() => _selectedCategory = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Difficulty',
                              value: _selectedDifficulty,
                              items: _difficulties,
                              onChanged: (value) => setState(() => _selectedDifficulty = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (\$)',
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Price is required';
                          if (double.tryParse(value!) == null) return 'Invalid price';
                          return null;
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Course Thumbnail Section
                  _buildSectionCard(
                    'Course Thumbnail',
                    Icons.image_outlined,
                    [
                      _buildThumbnailUpload(),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Lessons Section
                  _buildSectionCard(
                    'Course Lessons',
                    Icons.play_circle_outline,
                    [
                      _buildLessonsSection(),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Upload Button
                  _buildUploadButton(),
                  
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Upload Course',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
            )).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.white,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailUpload() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            style: BorderStyle.solid,
          ),
        ),
        child: _thumbnailFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      _thumbnailFile!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _thumbnailFile = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: Color(0xFF3B82F6),
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
                    'JPG, PNG up to 10MB',
                    style: GoogleFonts.inter(
                      fontSize: 12,
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
            Text(
              'Lessons (${_lessons.length})',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
            TextButton.icon(
              onPressed: _addLesson,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Lesson'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_lessons.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No lessons added yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add video lessons to your course',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow,
              size: 20,
              color: Color(0xFF3B82F6),
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
                ),
                const SizedBox(height: 2),
                Text(
                  'YouTube Video • ${lesson.formattedDuration}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeLesson(index),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isUploading || _lessons.isEmpty ? null : _uploadCourse,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
        ),
        child: _isUploading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Upload Course',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _thumbnailFile = File(image.path);
      });
    }
  }

  Future<void> _addLesson() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _LessonUploadDialog(),
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

  Future<void> _uploadCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a thumbnail')),
      );
      return;
    }
    if (_lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one lesson')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await SupabaseService.uploadCourseWithLessons(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        difficultyLevel: _selectedDifficulty,
        thumbnailFile: _thumbnailFile!,
        lessons: _lessons,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        setState(() => _isUploading = false);
      }
    }
  }
}

class _LessonUploadDialog extends StatefulWidget {
  @override
  State<_LessonUploadDialog> createState() => _LessonUploadDialogState();
}

class _LessonUploadDialogState extends State<_LessonUploadDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _videoFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add Lesson',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Lesson Title',
                hintText: 'Enter lesson title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe this lesson',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: _videoFile != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_file, size: 32, color: Color(0xFF3B82F6)),
                          const SizedBox(height: 8),
                          Text(
                            _videoFile!.path.split('/').last,
                            style: GoogleFonts.inter(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_call, size: 32, color: Color(0xFF6B7280)),
                          const SizedBox(height: 8),
                          Text(
                            'Select Video File',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSave() ? _saveLesson : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Add Lesson'),
        ),
      ],
    );
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty && _videoFile != null;
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    }
  }

  void _saveLesson() {
    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      'videoFile': _videoFile,
    });
  }
}
