import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final String profileImage = 'https://example.com/user_profile.jpg';
  final String username = 'Fitness Enthusiast';
  final String bio = 'Passionate about health and fitness. Sharing my journey!';
  final int followers = 432;
  final int following = 218;

  final List<Map<String, dynamic>> userPosts = [
    {
      'image': 'https://example.com/post1.jpg',
      'type': 'Cardio',
    },
    {
      'image': 'https://example.com/post2.jpg',
      'type': 'Strength',
    },
    {
      'image': 'https://example.com/post3.jpg',
      'type': 'Flexibility',
    },
    {
      'image': 'https://example.com/post4.jpg',
      'type': 'Endurance',
    },
  ];

  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImage(
                    imageUrl: profileImage,
                    fit: BoxFit.cover,
                  ).image,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(bio),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('$followers Followers'),
                          const SizedBox(width: 16),
                          Text('$following Following'),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey : Colors.green,
                  ),
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: post['image'],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on CachedNetworkImage {
  get image => null;
}
