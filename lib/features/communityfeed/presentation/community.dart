import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool _mounted = true;

  final ApiService apiService = ApiService("http://10.0.2.2:3000/api");

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
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

      if (fetchedPosts.isEmpty) {
        if (_mounted) {
          setState(() {
            posts = [];
            isLoading = false;
          });
        }
        return;
      }

      List<Map<String, dynamic>> postsWithUsernames = [];
      for (var post in fetchedPosts) {
        if (!mounted) return;

        try {
          final postMap = post is Map<String, dynamic>
              ? post
              : Map<String, dynamic>.from(post as Map);

          final userId = postMap['user_id'] is int
              ? postMap['user_id']
              : int.tryParse(postMap['user_id'].toString()) ?? 0;

          if (userId <= 0) continue;

          final user = await apiService.getCurrentUser(userId);
          if (!mounted) return;

          final username = user['username'] ?? 'Unknown User';

          postsWithUsernames.add({
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

      if (_mounted) {
        setState(() {
          posts = postsWithUsernames;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception in fetchPosts: $e');

      if (!mounted) return;

      if (_mounted) {
        setState(() {
          errorMessage = 'Failed to fetch posts: $e';
          isLoading = false;
        });
      }
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Date not available';
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(post['content']),
                                  const SizedBox(height: 8),
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
                          );
                        },
                      ),
                    ),
    );
  }
}
