import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPdf();
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName}.pdf');

      // Download PDF if not already cached
      if (!await file.exists()) {
        final response = await http.get(Uri.parse(widget.pdfUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download PDF: ${response.statusCode}');
        }
      }

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          if (_totalPages > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FEE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentPage + 1} / $_totalPages',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5B6FEE),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6FEE)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading PDF',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _downloadAndOpenPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B6FEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_localPath != null) {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            _totalPages = pages ?? 0;
          });
        },
        onViewCreated: (PDFViewController controller) {
          // PDF controller ready
        },
        onLinkHandler: (String? uri) {
          // Handle PDF links if needed
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
          });
        },
        onPageError: (page, error) {
          setState(() {
            _error = 'Error on page $page: $error';
          });
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        },
      );
    }

    return const Center(
      child: Text('No PDF to display'),
    );
  }
}
