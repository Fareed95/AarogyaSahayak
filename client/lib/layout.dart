// import 'package:client/screens/community_home.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/community_home.dart';
//
// // Add the required parameters here
// class Layout extends StatefulWidget {
//   final bool isDarkMode;
//   final VoidCallback onThemeToggle;
//
//   const Layout({
//     super.key,
//     required this.isDarkMode,
//     required this.onThemeToggle,
//   });
//
//   @override
//   State<Layout> createState() => _LayoutState();
// }
//
// class _LayoutState extends State<Layout> {
//   int _currentIndex = 0;
//
//   // Remove the local _isDarkMode state since we get it from parent
//   // bool _isDarkMode = false; // REMOVE THIS LINE
//
//   @override
//   void initState() {
//     super.initState();
//     // Remove _loadThemePreference since we get theme from parent
//     // _loadThemePreference(); // REMOVE THIS LINE
//   }
//
//   // Remove these methods since theme is now controlled by parent
//   // _loadThemePreference() async {...} // REMOVE
//   // _toggleTheme(bool value) async {...} // REMOVE
//
//   List<Widget> get _screens => const [
//     CommunitiesScreen(),
//     PostsScreen(),
//     ActivityScreen(),
//     ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Community'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 Icon(
//                   widget.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny, // Use widget.isDarkMode
//                   color: widget.isDarkMode ? Colors.white : Colors.black, // Use widget.isDarkMode
//                 ),
//                 const SizedBox(width: 8),
//                 Switch(
//                   value: widget.isDarkMode, // Use widget.isDarkMode
//                   onChanged: widget.onThemeToggle, // Use the callback from parent
//                   activeColor: Colors.white,
//                   activeTrackColor: Colors.grey,
//                   inactiveThumbColor: Colors.black,
//                   inactiveTrackColor: Colors.grey[300],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.group),
//             label: 'Communities',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.post_add),
//             label: 'Posts',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Activity',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
// // Communities Screen with Fallback
// class CommunitiesScreen extends StatelessWidget {
//   const CommunitiesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _loadCommunitiesWithFallback(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Colors.red.shade300,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'API Connection Error',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     'Error: ${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Trigger rebuild to retry
//                     (context as Element).markNeedsBuild();
//                   },
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Retry'),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: () {
//                     _showApiSetupDialog(context);
//                   },
//                   child: const Text('Check API Setup'),
//                 ),
//               ],
//             ),
//           );
//         } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.group_off, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text('No communities found'),
//               ],
//             ),
//           );
//         } else {
//           final communities = snapshot.data as List;
//           return ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: communities.length,
//             itemBuilder: (context, index) {
//               final community = communities[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     backgroundImage: community['profile_picture'] != null
//                         ? NetworkImage(community['profile_picture'])
//                         : null,
//                     child: community['profile_picture'] == null
//                         ? const Icon(Icons.group, color: Colors.white)
//                         : null,
//                   ),
//                   title: Text(
//                     community['name'] ?? 'Unknown Community',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Text(community['description'] ?? 'No description'),
//                   trailing: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         '${community['total_members_count'] ?? 0}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const Text('members', style: TextStyle(fontSize: 12)),
//                     ],
//                   ),
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Tapped on ${community['name']}'),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
//
//   Future<List<dynamic>> _loadCommunitiesWithFallback() async {
//     try {
//       return await CommunityApiService.getCommunities();
//     } catch (e) {
//       // If API fails, return mock data for testing
//       print('⚠️ API failed, using mock data: $e');
//       return CommunityApiService.getMockCommunities();
//     }
//   }
//
//   void _showApiSetupDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('API Setup Required'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('To fix this error, you need to:'),
//             SizedBox(height: 8),
//             Text('1. Update baseUrl in CommunityApiService'),
//             Text('2. Set the correct frontendSecret'),
//             Text('3. Ensure your API server is running'),
//             Text('4. Check your JWT token is valid'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Posts Screen with Fallback
// class PostsScreen extends StatelessWidget {
//   const PostsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _loadPostsWithFallback(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text('Error: ${snapshot.error}'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     (context as Element).markNeedsBuild();
//                   },
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.post_add, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text('No posts found'),
//               ],
//             ),
//           );
//         } else {
//           final posts = snapshot.data as List;
//           return ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: posts.length,
//             itemBuilder: (context, index) {
//               final post = posts[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         post['title'] ?? 'Untitled Post',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         post['content'] ?? 'No content',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Chip(
//                             label: Text(post['community_name'] ?? 'Unknown'),
//                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           const Spacer(),
//                           Row(
//                             children: [
//                               const Icon(Icons.thumb_up, size: 16),
//                               const SizedBox(width: 4),
//                               Text('${post['votes_like_count'] ?? 0}'),
//                               const SizedBox(width: 16),
//                               const Icon(Icons.thumb_down, size: 16),
//                               const SizedBox(width: 4),
//                               Text('${post['votes_dislike_count'] ?? 0}'),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
//
//   Future<List<dynamic>> _loadPostsWithFallback() async {
//     try {
//       return await CommunityApiService.getPosts();
//     } catch (e) {
//       print('⚠️ Posts API failed, using mock data: $e');
//       return CommunityApiService.getMockPosts();
//     }
//   }
// }
//
// // Activity Screen with Fallback
// class ActivityScreen extends StatelessWidget {
//   const ActivityScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _loadActivityWithFallback(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text('Error: ${snapshot.error}'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     (context as Element).markNeedsBuild();
//                   },
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         } else if (!snapshot.hasData) {
//           return const Center(child: Text('No activity found'));
//         } else {
//           final activity = snapshot.data as Map<String, dynamic>;
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'User Activity',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text('Email: ${activity['email'] ?? 'Unknown'}'),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Communities',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 8),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: (activity['communities'] as List?)?.length ?? 0,
//                     itemBuilder: (context, index) {
//                       final community = activity['communities'][index];
//                       return Card(
//                         child: ListTile(
//                           title: Text(community['community_name'] ?? 'Unknown'),
//                           subtitle: Text('Role: ${community['role'] ?? 'Unknown'}'),
//                           trailing: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text('Posts: ${community['user_posts_count'] ?? 0}'),
//                               Text('Likes: ${community['liked_posts_count'] ?? 0}'),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
//
//   Future<Map<String, dynamic>> _loadActivityWithFallback() async {
//     try {
//       return await CommunityApiService.getUserActivity();
//     } catch (e) {
//       print('⚠️ Activity API failed, using mock data: $e');
//       return CommunityApiService.getMockUserActivity();
//     }
//   }
// }
//
// // Simple Profile Screen
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.person, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text('Profile Screen'),
//           Text('API functionality will be added here'),
//         ],
//       ),
//     );
//   }
// }
import 'package:client/widgets/community_home.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/theme_switch.dart';
import '../services/info.dart';
import '../screens/home_screen.dart';
import '../screens/community_home.dart'; // Ensure this is a widget, not a service
import '../screens/nutrition.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';

class Layout extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  
  const Layout({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });
  
  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedIndex = 0;
  
  void _onDrawerItemTap(int index) {
    Navigator.pop(context); // Close drawer
    setState(() {
      selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(), // Widget
      const CommunityHome(),
      const Nutrition(), // Widget
      const ProfileScreen(), // Widget (PascalCase)
    ];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text(
          "Aarogya Sahayak",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          ThemeSwitch(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onThemeToggle,
          ),
          FutureBuilder<bool>(
            future: Info().isLoggedIn(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.data!
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const login_screen(), // PascalCase
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
            },
          ),
          const SizedBox(width: 8), // Small spacing from edge
        ],
      ),
      drawer: CustomDrawer(onItemTap: _onDrawerItemTap),
      body: pages[selectedIndex], // Now all items in `pages` are widgets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Nutrition",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "My Info",
          ),
        ],
      ),
    );
  }
}