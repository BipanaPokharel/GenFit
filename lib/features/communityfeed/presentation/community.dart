import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fyp/utils/api_service.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({Key? key}) : super(key: key);

  @override
  _CommunityFeedState createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String errorMessage = '';

  final ApiService apiService = ApiService("http://127.0.0.1:3000/api");

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedPosts = await apiService.getPosts();

      if (!mounted) return;

      final List<Map<String, dynamic>> processedPosts = [];

      for (final post in fetchedPosts) {
        try {
          final postMap = post is Map<String, dynamic>
              ? post
              : Map<String, dynamic>.from(post as Map);

          final author = postMap['author'] as Map<String, dynamic>?;
          final username = author?['username']?.toString() ?? 'Unknown User';

          processedPosts.add({
            'post_id': postMap['post_id'],
            'username': username,
            'content': postMap['content'] ?? '',
            'title': postMap['title'] ?? 'No Title',
            'created_at': postMap['created_at'] ?? '',
          });
        } catch (e) {
          print('Error processing post: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        posts = processedPosts;
        isLoading = false;
      });
    } catch (e) {
      print('Exception in fetchPosts: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to fetch posts: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Date not available';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPosts,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchPosts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : posts.isEmpty
                  ? const Center(
                      child: Text('No posts available'),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    post['username'][0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['username'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        post['title'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        post['content'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Posted on ${formatDate(post['created_at'])}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
