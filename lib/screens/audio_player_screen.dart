import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String fileName;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.fileName,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Set up audio player listeners
      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });

      // Load the audio
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          'Audio Player',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
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
              'Loading audio...',
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
              'Error loading audio',
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
              onPressed: _initializeAudio,
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Audio Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5B6FEE).withOpacity(0.8),
                  const Color(0xFF5B6FEE),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B6FEE).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.audiotrack,
              size: 80,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // File Name
          Text(
            widget.fileName,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Duration
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 32),

          // Progress Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF5B6FEE),
              inactiveTrackColor: const Color(0xFF5B6FEE).withOpacity(0.3),
              thumbColor: const Color(0xFF5B6FEE),
              overlayColor: const Color(0xFF5B6FEE).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
              onChanged: (value) {
                final position = Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                );
                _seek(position);
              },
            ),
          ),

          const SizedBox(height: 32),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous (disabled for now)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.skip_previous,
                  color: Color(0xFF9CA3AF),
                  size: 28,
                ),
              ),

              const SizedBox(width: 24),

              // Play/Pause
              GestureDetector(
                onTap: _playPause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5B6FEE),
                        Color(0xFF4F46E5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B6FEE).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Next (disabled for now)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.skip_next,
                  color: Color(0xFF9CA3AF),
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
