import 'package:flutter/material.dart';

// class VideoData {
//   final String id;
//   final String title;
//   final String description;
//   final String youtubeUrl;
//   final String thumbnailUrl;
//   final String duration;
//   final String category;

//   VideoData({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.youtubeUrl,
//     required this.thumbnailUrl,
//     required this.duration,
//     required this.category,
//   });

//   String get videoId {
//     final Uri uri = Uri.parse(youtubeUrl);
//     if (uri.host.contains('youtube.com')) {
//       return uri.queryParameters['v'] ?? '';
//     } else if (uri.host.contains('youtu.be')) {
//       return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
//     }
//     return '';
//   }

//   factory VideoData.fromJson(Map<String, dynamic> json) {
//     return VideoData(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       youtubeUrl: json['youtubeUrl'],
//       thumbnailUrl: json['thumbnailUrl'],
//       duration: json['duration'],
//       category: json['category'],
//     );
//   }
// }

// List<VideoData> mockVideoData = [
//   VideoData(
//     id: '1',
//     title: 'What is Nutrition?',
//     description: 'Understanding the basics of nutrition and why it matters for your health',
//     youtubeUrl: 'https://www.youtube.com/watch?v=bFtZCMhj5zY',
//     thumbnailUrl: 'https://img.youtube.com/vi/bFtZCMhj5zY/maxresdefault.jpg',
//     duration: '5:23',
//     category: 'Basics',
//   ),
//   VideoData(
//     id: '2',
//     title: 'How to Read Nutrition Labels',
//     description: 'Learn to decode nutrition labels and make informed food choices',
//     youtubeUrl: 'https://www.youtube.com/watch?v=T8lEWIkLUAM',
//     thumbnailUrl: 'https://img.youtube.com/vi/T8lEWIkLUAM/maxresdefault.jpg',
//     duration: '7:45',
//     category: 'Food Labels',
//   ),
//   VideoData(
//     id: '3',
//     title: 'Balanced Diet Guide',
//     description: 'Discover what makes a balanced diet and proper nutrition',
//     youtubeUrl: 'https://www.youtube.com/watch?v=3E_bONqP9ps',
//     thumbnailUrl: 'https://img.youtube.com/vi/3E_bONqP9ps/maxresdefault.jpg',
//     duration: '9:12',
//     category: 'Diet Planning',
//   ),
//   VideoData(
//     id: '4',
//     title: 'Hydration & Health',
//     description: 'Understanding how proper hydration affects your health',
//     youtubeUrl: 'https://www.youtube.com/watch?v=9iMGFqMmUFs',
//     thumbnailUrl: 'https://img.youtube.com/vi/9iMGFqMmUFs/maxresdefault.jpg',
//     duration: '6:30',
//     category: 'Hydration',
//   ),
//   VideoData(
//     id: '5',
//     title: 'Vitamins & Minerals',
//     description: 'Learn about essential vitamins and minerals your body needs',
//     youtubeUrl: 'https://www.youtube.com/watch?v=Q8QQyUHN5C4',
//     thumbnailUrl: 'https://img.youtube.com/vi/Q8QQyUHN5C4/maxresdefault.jpg',
//     duration: '11:25',
//     category: 'Micronutrients',
//   ),
//   VideoData(
//     id: '6',
//     title: 'Heart Healthy Foods',
//     description: 'Foods that promote cardiovascular health and prevent disease',
//     youtubeUrl: 'https://www.youtube.com/watch?v=WUFu6dkj5cY',
//     thumbnailUrl: 'https://img.youtube.com/vi/WUFu6dkj5cY/maxresdefault.jpg',
//     duration: '8:17',
//     category: 'Heart Health',
//   ),
// ];

// class Nutrition extends StatefulWidget {
//   const Nutrition({super.key});

//   @override
//   State<Nutrition> createState() => _NutritionState();
// }

// class _NutritionState extends State<Nutrition> {
//   bool isReadMoreExpanded = false;
  
//   List<VideoData> displayedVideos = [];
//   int currentVideoIndex = 0;
//   final int videosPerLoad = 2;
  
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _loadMoreVideos();
    
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >= 
//         _scrollController.position.maxScrollExtent - 200) {
//       _loadMoreVideos();
//     }
//   }

//   void _loadMoreVideos() {
//     if (currentVideoIndex < mockVideoData.length) {
//       setState(() {
//         final endIndex = (currentVideoIndex + videosPerLoad).clamp(0, mockVideoData.length);
//         displayedVideos.addAll(mockVideoData.sublist(currentVideoIndex, endIndex));
//         currentVideoIndex = endIndex;
//       });
//     }
//   }

//   void _toggleReadMore() {
//     setState(() {
//       isReadMoreExpanded = !isReadMoreExpanded;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFA),
      
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderSection(),
            
//             const SizedBox(height: 24),
            
//             _buildVideoGrid(),
            
//             const SizedBox(height: 32),
            
//             _buildContentSection(),
            
//             const SizedBox(height: 24),
            
//             if (currentVideoIndex < mockVideoData.length)
//               _buildLoadingIndicator(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Header section widget
//   Widget _buildHeaderSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF2E7D8F).withOpacity(0.1),
//             const Color(0xFF4A9FB8).withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF2E7D8F).withOpacity(0.1),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Nutrition Education Hub',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF2E7D8F),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Discover expert insights on nutrition and healthy living',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Video grid builder
//   Widget _buildVideoGrid() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Featured Videos',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF2E7D8F),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Grid of videos - displays two videos per row
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: (displayedVideos.length / 2).ceil(),
//           separatorBuilder: (context, index) => const SizedBox(height: 16),
//           itemBuilder: (context, index) {
//             final startIndex = index * 2;
//             final endIndex = (startIndex + 2).clamp(0, displayedVideos.length);
//             final rowVideos = displayedVideos.sublist(startIndex, endIndex);
            
//             return Row(
//               children: [
//                 // First video in row
//                 Expanded(
//                   child: VideoCard(videoData: rowVideos[0]),
//                 ),
                
//                 // Second video in row (if exists)
//                 if (rowVideos.length > 1) ...[
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: VideoCard(videoData: rowVideos[1]),
//                   ),
//                 ],
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // Content section with read more functionality
//   Widget _buildContentSection() {
//     const String shortText = "NutriScan helps you make informed decisions about your nutrition. "
//         "Our comprehensive database provides detailed nutritional information "
//         "to support your health journey.";
    
//     const String fullText = "$shortText\n\n"
//         "With advanced scanning technology, you can quickly analyze food products, "
//         "understand ingredient lists, and track your nutritional intake. Our expert "
//         "nutritionists have curated educational content to help you understand "
//         "the science behind healthy eating.\n\n"
//         "Key features include calorie tracking, macro and micronutrient analysis, "
//         "personalized recommendations, and integration with your health goals. "
//         "Whether you're managing a specific dietary requirement or simply want "
//         "to eat more mindfully, NutriScan provides the tools you need.";

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'About NutriScan',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF2E7D8F),
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Content text
//           Text(
//             isReadMoreExpanded ? fullText : shortText,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[700],
//               height: 1.6,
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           // Read more button
//           GestureDetector(
//             onTap: _toggleReadMore,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2E7D8F).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: const Color(0xFF2E7D8F).withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     isReadMoreExpanded ? 'Read Less' : 'Read More',
//                     style: const TextStyle(
//                       color: Color(0xFF2E7D8F),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Icon(
//                     isReadMoreExpanded 
//                         ? Icons.keyboard_arrow_up 
//                         : Icons.keyboard_arrow_down,
//                     color: const Color(0xFF2E7D8F),
//                     size: 18,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Loading indicator for lazy loading
//   Widget _buildLoadingIndicator() {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   const Color(0xFF2E7D8F),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Loading more videos...',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Reusable Video Card Component
// class VideoCard extends StatelessWidget {
//   final VideoData videoData;

//   const VideoCard({
//     Key? key,
//     required this.videoData,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Video thumbnail with play button
//           Container(
//             height: 180,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//               color: Colors.grey[100],
//             ),
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//               child: _buildVideoThumbnail(),
//             ),
//           ),
          
//           // Video info
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2E7D8F).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     videoData.category,
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF2E7D8F),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Video title
//                 Text(
//                   videoData.title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2E7D8F),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 const SizedBox(height: 6),
                
//                 // Video description
//                 Text(
//                   videoData.description,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                     height: 1.4,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 // Duration and action row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Duration
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 14,
//                           color: Colors.grey[500],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           videoData.duration,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     // Watch button
//                     GestureDetector(
//                       onTap: () => _showVideoModal(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2E7D8F),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.play_arrow,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 4),
//                             const Text(
//                               'Watch',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Build video thumbnail with play button overlay
//   Widget _buildVideoThumbnail() {
//     return Stack(
//       children: [
//         // Thumbnail placeholder (since we can't load external images without packages)
//         Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 const Color(0xFF2E7D8F).withOpacity(0.8),
//                 const Color(0xFF4A9FB8).withOpacity(0.6),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.play_circle_filled,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   videoData.category,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Show video details modal
//   void _showVideoModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               // Modal handle
//               Container(
//                 margin: const EdgeInsets.only(top: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
              
//               // Modal content
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Video thumbnail
//                       Container(
//                         height: 200,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               const Color(0xFF2E7D8F).withOpacity(0.8),
//                               const Color(0xFF4A9FB8).withOpacity(0.6),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.play_circle_filled,
//                             size: 60,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
                      
//                       const SizedBox(height: 16),
                      
//                       // Video title
//                       Text(
//                         videoData.title,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2E7D8F),
//                         ),
//                       ),
                      
//                       const SizedBox(height: 8),
                      
//                       // Category and duration
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF2E7D8F).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               videoData.category,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xFF2E7D8F),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Icon(
//                             Icons.access_time,
//                             size: 16,
//                             color: Colors.grey[500],
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             videoData.duration,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 16),
                      
//                       // Description
//                       Text(
//                         'About this video:',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2E7D8F),
//                         ),
//                       ),
                      
//                       const SizedBox(height: 8),
                      
//                       Text(
//                         videoData.description,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[700],
//                           height: 1.5,
//                         ),
//                       ),
                      
//                       const SizedBox(height: 20),
                      
//                       // Video URL info
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Video Link:',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               videoData.youtubeUrl,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               'Copy this link to watch the video in your browser or YouTube app.',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      youtubeUrl: json['youtubeUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      duration: json['duration'] as String,
      category: json['category'] as String,
    );
  }
}

// Mock Video Data
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

// Main Application Widget
class NutritionApp extends StatelessWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition Hub',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      themeMode: ThemeMode.system, // Or .light, .dark
      home: const Nutrition(),
    );
  }
}

// VideoCard Widget
class VideoCard extends StatelessWidget {
  final VideoData videoData;
  final VoidCallback onWatchPressed;

  const VideoCard({
    Key? key,
    required this.videoData,
    required this.onWatchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 340, // Increased height to accommodate content properly
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF14213D).withOpacity(0.5) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
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
            height: 160, // Reduced thumbnail height slightly
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.network(
                      videoData.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // Dark overlay
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: onWatchPressed,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCA311).withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12), // Reduced padding slightly
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCA311).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      videoData.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFCA311),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Video title
                  Text(
                    videoData.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF14213D),
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
                      color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
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
                            color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            videoData.duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      // Watch button
                      GestureDetector(
                        onTap: onWatchPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCA311),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
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
          ),
        ],
      ),
    );
  }
}

// NutriScan Camera Section
class NutriScanCameraSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onScanFood;

  const NutriScanCameraSection({
    Key? key,
    required this.isDark,
    required this.onScanFood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.white,
            isDark ? const Color(0xFF14213D).withOpacity(0.1) : const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF14213D).withOpacity(0.5) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFCA311).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: Color(0xFFFCA311),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NutriScan Camera',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan food items to get instant nutritional analysis including calories, macros, and detailed reports',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onScanFood,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCA311),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFCA311).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.qr_code_scanner, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Start Scanning',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Daily Protein Tracker Widget
class DailyProteinTracker extends StatelessWidget {
  final bool isDark;
  final int currentProtein;
  final int proteinGoal;
  final VoidCallback onAddProtein;

  const DailyProteinTracker({
    Key? key,
    required this.isDark,
    required this.currentProtein,
    required this.proteinGoal,
    required this.onAddProtein,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = currentProtein / proteinGoal;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF14213D).withOpacity(0.5) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Daily Protein Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF14213D),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCA311).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFCA311),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCA311),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${currentProtein}g / ${proteinGoal}g protein',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFE5E5E5) : const Color(0xFF14213D),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFCA311),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Add protein button
          GestureDetector(
            onTap: currentProtein >= proteinGoal ? null : onAddProtein,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: currentProtein >= proteinGoal ? Colors.grey : const Color(0xFFFCA311),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    currentProtein >= proteinGoal ? Icons.check : Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentProtein >= proteinGoal ? 'Goal Reached!' : 'Add Protein (+5g)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Nutrition Header Section Widget
class NutritionHeader extends StatelessWidget {
  final bool isDark;

  const NutritionHeader({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? const Color(0xFF14213D).withOpacity(0.3) : const Color(0xFFFCA311).withOpacity(0.1),
            isDark ? const Color(0xFF14213D).withOpacity(0.1) : const Color(0xFFFCA311).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF14213D).withOpacity(0.3) : const Color(0xFFFCA311).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Nutrition Education Hub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover expert insights on nutrition and healthy living',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Video Grid Section Widget
class VideoGridSection extends StatelessWidget {
  final bool isDark;
  final List<VideoData> displayedVideos;
  final ValueChanged<VideoData> onVideoWatchPressed;

  const VideoGridSection({
    Key? key,
    required this.isDark,
    required this.displayedVideos,
    required this.onVideoWatchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Featured Videos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 16),

        // Grid of videos - displays two videos per row
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (displayedVideos.length / 2).ceil(),
          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
          itemBuilder: (BuildContext context, int index) {
            final int startIndex = index * 2;
            final int endIndex = (startIndex + 2).clamp(0, displayedVideos.length);
            final List<VideoData> rowVideos = displayedVideos.sublist(startIndex, endIndex);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
              children: <Widget>[
                // First video in row
                Expanded(
                  child: VideoCard(
                    videoData: rowVideos[0],
                    onWatchPressed: () => onVideoWatchPressed(rowVideos[0]),
                  ),
                ),

                // Second video in row (if exists)
                if (rowVideos.length > 1) ...<Widget>[
                  const SizedBox(width: 12),
                  Expanded(
                    child: VideoCard(
                      videoData: rowVideos[1],
                      onWatchPressed: () => onVideoWatchPressed(rowVideos[1]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

// About NutriScan Section Widget
class AboutNutriScanSection extends StatefulWidget {
  final bool isDark;

  const AboutNutriScanSection({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  State<AboutNutriScanSection> createState() => _AboutNutriScanSectionState();
}

class _AboutNutriScanSectionState extends State<AboutNutriScanSection> {
  bool isReadMoreExpanded = false;

  void _toggleReadMore() {
    setState(() {
      isReadMoreExpanded = !isReadMoreExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        color: widget.isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF14213D).withOpacity(0.5) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'About NutriScan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : const Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 12),

          // Content text
          Text(
            isReadMoreExpanded ? fullText : shortText,
            style: TextStyle(
              fontSize: 16,
              color: widget.isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[700],
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
                color: const Color(0xFFFCA311).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFCA311).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    isReadMoreExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: Color(0xFFFCA311),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isReadMoreExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFFFCA311),
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
}

// Loading Indicator Widget
class LoadingIndicator extends StatelessWidget {
  final bool isDark;

  const LoadingIndicator({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFFCA311),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more videos...',
              style: TextStyle(
                color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Nutrition Screen
class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition> {
  int proteinGoal = 50;
  int currentProtein = 23;

  List<VideoData> displayedVideos = <VideoData>[];
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
        final int endIndex = (currentVideoIndex + videosPerLoad).clamp(0, mockVideoData.length);
        displayedVideos.addAll(mockVideoData.sublist(currentVideoIndex, endIndex));
        currentVideoIndex = endIndex;
      });
    }
  }

  void _scanFood() {
    // Camera scanner functionality placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening camera scanner...'),
        backgroundColor: Color(0xFFFCA311),
      ),
    );
  }

  void _addProtein() {
    if (currentProtein < proteinGoal) {
      setState(() {
        currentProtein = (currentProtein + 5).clamp(0, proteinGoal);
      });
    }
  }

  void _showVideoModal(VideoData videoData) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14213D) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: <Widget>[
              // Modal handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.3) : Colors.grey[300],
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
                    children: <Widget>[
                      // Video thumbnail
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Image.network(
                                  videoData.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.3), // Dark overlay
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  size: 60,
                                  color: Color(0xFFFCA311),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Video title
                      Text(
                        videoData.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF14213D),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Category and duration
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCA311).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              videoData.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFCA311),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            videoData.duration,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'About this video:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF14213D),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        videoData.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Video URL info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF14213D).withOpacity(0.3) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Video Link:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              videoData.youtubeUrl,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Copy this link to watch the video in your browser or YouTube app.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.6) : Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Camera Scanner Section
            NutriScanCameraSection(
              isDark: isDark,
              onScanFood: _scanFood,
            ),

            const SizedBox(height: 24),

            // Daily Protein Tracker Section
            DailyProteinTracker(
              isDark: isDark,
              currentProtein: currentProtein,
              proteinGoal: proteinGoal,
              onAddProtein: _addProtein,
            ),

            const SizedBox(height: 24),

            VideoGridSection(
              isDark: isDark,
              displayedVideos: displayedVideos,
              onVideoWatchPressed: _showVideoModal,
            ),

            const SizedBox(height: 32),

            AboutNutriScanSection(
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            if (currentVideoIndex < mockVideoData.length)
              LoadingIndicator(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const NutritionApp());
}