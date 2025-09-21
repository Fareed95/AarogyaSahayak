import 'package:flutter/material.dart';
import '../screens/community_home.dart'; // CommunityApiService lives here

class CommunityHome extends StatefulWidget {
  const CommunityHome({super.key});

  @override
  State<CommunityHome> createState() => _CommunityHomeState();
}

class _CommunityHomeState extends State<CommunityHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _communitiesFuture;
  late Future<List<dynamic>> _postsFuture;
  late Future<Map<String, dynamic>> _userActivityFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // For now use mock data so UI works even without backend
    _communitiesFuture = Future.value(CommunityApiService.getMockCommunities());
    _postsFuture = Future.value(CommunityApiService.getMockPosts());
    _userActivityFuture = Future.value(CommunityApiService.getMockUserActivity());
    
    // Later, replace with:
    // _communitiesFuture = CommunityApiService.getCommunities();
    // _postsFuture = CommunityApiService.getPosts();
    // _userActivityFuture = CommunityApiService.getUserActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createCommunity() {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController descController = TextEditingController();

        return AlertDialog(
          title: const Text("Create Community"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Community Name"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    CommunityApiService.getMockCommunities().add({
                      "id": DateTime.now().millisecondsSinceEpoch,
                      "name": nameController.text,
                      "description": descController.text,
                      "created_at": DateTime.now().toIso8601String(),
                      "total_members_count": 1,
                      "user_role": "admin",
                      "profile_picture": null,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _showCommunityDetails(Map<String, dynamic> community) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return CommunityDetailSheet(
              community: community,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    return FutureBuilder<List<dynamic>>(
      future: _communitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("❌ Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No communities found."));
        }

        final communities = snapshot.data!;

        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    community['name'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(community['name']),
                subtitle: Text(
                  community['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Joined ${community['name']} ✅"),
                      ),
                    );
                  },
                  child: const Text("Join"),
                ),
                onTap: () => _showCommunityDetails(community),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("❌ Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posts found."));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            post['community_name'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['community_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Posted by ${post['author']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(post['content']),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_upward,
                            color: post['user_vote'] == 1 ? Colors.orange : Colors.grey,
                          ),
                          onPressed: () {
                            // Handle upvote
                          },
                        ),
                        Text('${post['votes']}'),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_downward,
                            color: post['user_vote'] == -1 ? Colors.purple : Colors.grey,
                          ),
                          onPressed: () {
                            // Handle downvote
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark,
                            color: post['saved'] ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            // Handle save
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            // Handle comment
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userActivityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("❌ Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No activity data found."));
        }

        final activity = snapshot.data!;
        final joinedCommunities = activity['joined_communities'] as List<dynamic>;
        final stats = activity['stats'] as Map<String, dynamic>;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Stats',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Posts', stats['posts_count']),
                            _buildStatItem('Likes', stats['likes_count']),
                            _buildStatItem('Saves', stats['saves_count']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Joined Communities Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Joined Communities (${joinedCommunities.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              if (joinedCommunities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('You haven\'t joined any communities yet.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: joinedCommunities.length,
                  itemBuilder: (context, index) {
                    final community = joinedCommunities[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          community['name'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(community['name']),
                      subtitle: Text('${community['member_count']} members'),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communities"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: "Communities"),
            Tab(icon: Icon(Icons.post_add), text: "Posts"),
            Tab(icon: Icon(Icons.home_mini), text: "My Activity"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunitiesTab(),
          _buildPostsTab(),
          _buildActivityTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createCommunity,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class CommunityDetailSheet extends StatelessWidget {
  final Map<String, dynamic> community;
  final ScrollController scrollController;

  const CommunityDetailSheet({
    super.key,
    required this.community,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 30,
                child: Text(
                  community['name'][0],
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community['name'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${community['total_members_count']} members',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            community['description'] ?? 'No description provided',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Joined ${community['name']} ✅"),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Join Community"),
          ),
          const SizedBox(height: 16),
          const Text(
            "Recent Posts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: Future.value(CommunityApiService.getMockPostsForCommunity(community['id'])),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("❌ Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No posts in this community yet."));
                }

                final posts = snapshot.data!;

                return ListView.builder(
                  controller: scrollController,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post['content'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward, size: 20),
                                  onPressed: () {},
                                ),
                                Text('${post['votes']}'),
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward, size: 20),
                                  onPressed: () {},
                                ),
                                const Spacer(),
                                Text(
                                  '${post['comment_count']} comments',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Mock service class (to be replaced with your actual implementation)
class CommunityApiService {
  static List<dynamic> getMockCommunities() {
    return [
      {
        "id": 1,
        "name": "Acid Attach Survivors",
        "description": "A safe space for survivors of acid attacks to share their stories and support each other",
        "created_at": "2023-01-15T10:30:00Z",
        "total_members_count": 1250,
        "user_role": "member",
        "profile_picture": null,
      },
      {
        "id": 2,
        "name": "PCOD/PCOS Support Group",
        "description": "A supportive community for individuals dealing with PCOD/PCOS",
        "created_at": "2023-02-20T14:45:00Z",
        "total_members_count": 890,
        "user_role": "non-member",
        "profile_picture": null,
      },
      {
        "id": 3,
        "name": "Alzheimer's Caregivers",
        "description": "A community for caregivers of Alzheimer's patients to share advice and experiences",
        "created_at": "2023-03-10T09:15:00Z",
        "total_members_count": 2100,
        "user_role": "non-member",
        "profile_picture": null,
      },
    ];
  }

  static List<dynamic> getMockPosts() {
    return [
      {
        "id": 1,
        "title": "How to take care of elderly parents",
        "content": "Sharing some tips and experiences on caring for aging parents...",
        "author": "JohnDoe",
        "community_name": "Elder Care",
        "votes": 42,
        "comment_count": 15,
        "saved": false,
        "user_vote": 1,
      },
      {
        "id": 2,
        "title": "How Honey is a Natural Remedy for Cough and Cold",
        "content": "Honey has been used for centuries as a natural remedy for cough and cold symptoms...",
        "author": "JaneSmith",
        "community_name": "Home Remedies",
        "votes": 28,
        "comment_count": 8,
        "saved": true,
        "user_vote": 0,
      },
      {
        "id": 3,
        "title": "Sarso ka tel is beneficial for hair growth",
        "content": "Mustard oil, known as 'Sarso ka tel' in Hindi, is widely used in India for hair care...",
        "author": "GhareluNuskhe",
        "community_name": "Tech News",
        "votes": 105,
        "comment_count": 32,
        "saved": false,
        "user_vote": -1,
      },
    ];
  }

  static Map<String, dynamic> getMockUserActivity() {
    return {
      "joined_communities": [
        {
          "id": 1,
          "name": "Stand Against Acid Attacks",
          "member_count": 1250,
        },
        {
          "id": 4,
          "name": "Stand againt Rape",
          "member_count": 950,
        },
      ],
      "stats": {
        "posts_count": 15,
        "likes_count": 42,
        "saves_count": 8,
      }
    };
  }

  static List<dynamic> getMockPostsForCommunity(int communityId) {
    return getMockPosts().where((post) => post['id'] == communityId).toList();
  }
}