import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideosScreen
    extends
        StatefulWidget {
  final int pk;
  const YouTubeVideosScreen({
    super.key,
    required this.pk,
  });

  @override
  State<
    YouTubeVideosScreen
  >
  createState() => _YouTubeVideosScreenState();
}

class _YouTubeVideosScreenState
    extends
        State<
          YouTubeVideosScreen
        > {
  final SecureStorageService _storageService = SecureStorageService();
  bool _loading = true;
  List<
    dynamic
  >
  _videos = [];

  @override
  void initState() {
    super.initState();
    fetchYouTubeVideos();
  }

  Future<
    void
  >
  fetchYouTubeVideos() async {
    try {
      String? token = await _storageService.getJwtToken();
      if (token ==
          null)
        throw Exception(
          'JWT Token not found',
        );

      final response = await http.get(
        Uri.parse(
          'http://192.168.0.107:8000/api/reports/get_user_instances/?pk=${widget.pk}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      print(
        '🔹 Status: ${response.statusCode}',
      );
      print(
        '🔹 Body: ${response.body}',
      );

      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );

        setState(
          () {
            _videos =
                data['report_instance']?['youtube_videos'] ??
                [];
            _loading = false;
          },
        );
      } else {
        throw Exception(
          'Failed to fetch YouTube videos: ${response.statusCode}',
        );
      }
    } catch (
      e
    ) {
      print(
        'Error: $e',
      );
      setState(
        () {
          _loading = false;
        },
      );
    }
  }

  void _launchURL(
    String url,
  ) async {
    final uri = Uri.parse(
      url,
    );
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception(
        'Could not launch $url',
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YouTube Videos',
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _videos.isEmpty
          ? const Center(
              child: Text(
                'No YouTube videos found',
              ),
            )
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final video = _videos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        leading: Image.network(
                          video['thumbnails']?['default']?['url'] ??
                              'https://via.placeholder.com/120x90',
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          video['title'] ??
                              'No Title',
                        ),
                        subtitle: Text(
                          video['channel'] ??
                              '',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    _,
                                  ) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(
                                        video['title'] ??
                                            'Video',
                                      ),
                                    ),
                                    body: YoutubePlayer(
                                      controller: YoutubePlayerController(
                                        initialVideoId: video['video_id'],
                                        flags: const YoutubePlayerFlags(
                                          autoPlay: true,
                                          mute: false,
                                        ),
                                      ),
                                      showVideoProgressIndicator: true,
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
            ),
    );
  }
}
