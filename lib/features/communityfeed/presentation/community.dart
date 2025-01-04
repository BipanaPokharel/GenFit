import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({super.key});

  @override
  _CommunityFeedState createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Fitness Enthusiast',
      'profileImage': 'https://example.com/profile1.jpg',
      'content': 'Just crushed my daily workout on the treadmill!',
      'likes': 24,
      'comments': 8,
      'shares': 3,
    },
    {
      'username': 'Workout Warrior',
      'profileImage': 'https://example.com/profile2.jpg',
      'content': 'Trying out the new resistance bands, feeling the burn!',
      'likes': 31,
      'comments': 12,
      'shares': 5,
    },
    {
      'username': 'Gym Junkie',
      'profileImage': 'https://example.com/profile3.jpg',
      'content': 'Loving my new kettlebell, great addition to my home gym!',
      'likes': 19,
      'comments': 6,
      'shares': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImage(
                        imageUrl: post['profileImage'],
                        fit: BoxFit.cover,
                      ).image,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post['username'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post['content']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text('${post['likes']}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.comment, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text('${post['comments']}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.share, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text('${post['shares']}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on CachedNetworkImage {
  get image => null;
}
