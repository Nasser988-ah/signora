import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class LessonUploadDialog extends StatefulWidget {
  @override
  _LessonUploadDialogState createState() => _LessonUploadDialogState();
}

class _LessonUploadDialogState extends State<LessonUploadDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _videoFile;
  

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 350,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Lesson',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson Title
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Lesson Title',
                        hintText: 'Enter lesson title',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                        hintStyle: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF5B6FEE), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Brief description...',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                        hintStyle: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF5B6FEE), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Video Upload
                    GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _videoFile != null ? const Color(0xFF5B6FEE).withOpacity(0.1) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _videoFile != null ? const Color(0xFF5B6FEE) : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _videoFile != null ? Icons.check_circle : Icons.video_library_outlined,
                              size: 32,
                              color: _videoFile != null ? const Color(0xFF5B6FEE) : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _videoFile != null ? 'Video Selected' : 'Select Video',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _videoFile != null ? const Color(0xFF5B6FEE) : const Color(0xFF6B7280),
                              ),
                            ),
                            if (_videoFile != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _videoFile!.path.split('/').last.length > 25
                                    ? '${_videoFile!.path.split('/').last.substring(0, 25)}...'
                                    : _videoFile!.path.split('/').last,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _titleController.text.isNotEmpty && _videoFile != null
                                ? () {
                                    Navigator.of(context).pop({
                                      'title': _titleController.text,
                                      'description': _descriptionController.text,
                                      'videoFile': _videoFile,
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B6FEE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Add',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
