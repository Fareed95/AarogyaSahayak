import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: const Center(
        child: Text('Nutrition Screen Content'),
      ),
    );
  }
class VideoData {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String duration;
  final String category;

  VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.category,
  });

  String get videoId {
    final Uri uri = Uri.parse(youtubeUrl);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    }
    return '';
  }

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      youtubeUrl: json['youtubeUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      category: json['category'],
    );
  }
}

List<VideoData> mockVideoData = [
  VideoData(
    id: '1',
    title: 'What is Nutrition?',
    description: 'Understanding the basics of nutrition and why it matters for your health',
    youtubeUrl: 'https://www.youtube.com/watch?v=bFtZCMhj5zY',
    thumbnailUrl: 'https://img.youtube.com/vi/bFtZCMhj5zY/maxresdefault.jpg',
    duration: '5:23',
    category: 'Basics',
  ),
  VideoData(
    id: '2',
    title: 'How to Read Nutrition Labels',
    description: 'Learn to decode nutrition labels and make informed food choices',
    youtubeUrl: 'https://www.youtube.com/watch?v=T8lEWIkLUAM',
    thumbnailUrl: 'https://img.youtube.com/vi/T8lEWIkLUAM/maxresdefault.jpg',
    duration: '7:45',
    category: 'Food Labels',
  ),
  VideoData(
    id: '3',
    title: 'Balanced Diet Guide',
    description: 'Discover what makes a balanced diet and proper nutrition',
    youtubeUrl: 'https://www.youtube.com/watch?v=3E_bONqP9ps',
    thumbnailUrl: 'https://img.youtube.com/vi/3E_bONqP9ps/maxresdefault.jpg',
    duration: '9:12',
    category: 'Diet Planning',
  ),
  VideoData(
    id: '4',
    title: 'Hydration & Health',
    description: 'Understanding how proper hydration affects your health',
    youtubeUrl: 'https://www.youtube.com/watch?v=9iMGFqMmUFs',
    thumbnailUrl: 'https://img.youtube.com/vi/9iMGFqMmUFs/maxresdefault.jpg',
    duration: '6:30',
    category: 'Hydration',
  ),
  VideoData(
    id: '5',
    title: 'Vitamins & Minerals',
    description: 'Learn about essential vitamins and minerals your body needs',
    youtubeUrl: 'https://www.youtube.com/watch?v=Q8QQyUHN5C4',
    thumbnailUrl: 'https://img.youtube.com/vi/Q8QQyUHN5C4/maxresdefault.jpg',
    duration: '11:25',
    category: 'Micronutrients',
  ),
  VideoData(
    id: '6',
    title: 'Heart Healthy Foods',
    description: 'Foods that promote cardiovascular health and prevent disease',
    youtubeUrl: 'https://www.youtube.com/watch?v=WUFu6dkj5cY',
    thumbnailUrl: 'https://img.youtube.com/vi/WUFu6dkj5cY/maxresdefault.jpg',
    duration: '8:17',
    category: 'Heart Health',
  ),
];

class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition> {
  bool isReadMoreExpanded = false;
  
  List<VideoData> displayedVideos = [];
  int currentVideoIndex = 0;
  final int videosPerLoad = 2;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreVideos();
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreVideos();
    }
  }

  void _loadMoreVideos() {
    if (currentVideoIndex < mockVideoData.length) {
      setState(() {
        final endIndex = (currentVideoIndex + videosPerLoad).clamp(0, mockVideoData.length);
        displayedVideos.addAll(mockVideoData.sublist(currentVideoIndex, endIndex));
        currentVideoIndex = endIndex;
      });
    }
  }

  void _toggleReadMore() {
    setState(() {
      isReadMoreExpanded = !isReadMoreExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            
            const SizedBox(height: 24),
            
            _buildVideoGrid(),
            
            const SizedBox(height: 32),
            
            _buildContentSection(),
            
            const SizedBox(height: 24),
            
            if (currentVideoIndex < mockVideoData.length)
              _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  // Header section widget
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D8F).withOpacity(0.1),
            const Color(0xFF4A9FB8).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D8F).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Education Hub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover expert insights on nutrition and healthy living',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Video grid builder
  Widget _buildVideoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Videos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D8F),
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid of videos - displays two videos per row
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (displayedVideos.length / 2).ceil(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final startIndex = index * 2;
            final endIndex = (startIndex + 2).clamp(0, displayedVideos.length);
            final rowVideos = displayedVideos.sublist(startIndex, endIndex);
            
            return Row(
              children: [
                // First video in row
                Expanded(
                  child: VideoCard(videoData: rowVideos[0]),
                ),
                
                // Second video in row (if exists)
                if (rowVideos.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: VideoCard(videoData: rowVideos[1]),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // Content section with read more functionality
  Widget _buildContentSection() {
    const String shortText = "NutriScan helps you make informed decisions about your nutrition. "
        "Our comprehensive database provides detailed nutritional information "
        "to support your health journey.";
    
    const String fullText = "$shortText\n\n"
        "With advanced scanning technology, you can quickly analyze food products, "
        "understand ingredient lists, and track your nutritional intake. Our expert "
        "nutritionists have curated educational content to help you understand "
        "the science behind healthy eating.\n\n"
        "Key features include calorie tracking, macro and micronutrient analysis, "
        "personalized recommendations, and integration with your health goals. "
        "Whether you're managing a specific dietary requirement or simply want "
        "to eat more mindfully, NutriScan provides the tools you need.";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About NutriScan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 12),
          
          // Content text
          Text(
            isReadMoreExpanded ? fullText : shortText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Read more button
          GestureDetector(
            onTap: _toggleReadMore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D8F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2E7D8F).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isReadMoreExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: Color(0xFF2E7D8F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isReadMoreExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2E7D8F),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading indicator for lazy loading
  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF2E7D8F),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more videos...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Video Card Component
class VideoCard extends StatelessWidget {
  final VideoData videoData;

  const VideoCard({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail with play button
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: _buildVideoThumbnail(),
            ),
          ),
          
          // Video info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D8F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    videoData.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E7D8F),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Video title
                Text(
                  videoData.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D8F),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Video description
                Text(
                  videoData.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Duration and action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          videoData.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    
                    // Watch button
                    GestureDetector(
                      onTap: () => _showVideoModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D8F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Watch',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
    );
  }

  // Build video thumbnail with play button overlay
  Widget _buildVideoThumbnail() {
    return Stack(
      children: [
        // Thumbnail placeholder (since we can't load external images without packages)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D8F).withOpacity(0.8),
                const Color(0xFF4A9FB8).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  videoData.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Show video details modal
  void _showVideoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Modal handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Modal content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video thumbnail
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2E7D8F).withOpacity(0.8),
                              const Color(0xFF4A9FB8).withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Video title
                      Text(
                        videoData.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Category and duration
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D8F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              videoData.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2E7D8F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            videoData.duration,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'About this video:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D8F),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        videoData.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Video URL info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Video Link:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              videoData.youtubeUrl,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Copy this link to watch the video in your browser or YouTube app.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
>>>>>>> da432e39a4fd007c1b35cd606b4c40fd89ad3034
}