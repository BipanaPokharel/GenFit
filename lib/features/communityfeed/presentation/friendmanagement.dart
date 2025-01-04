import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FriendManagement extends StatefulWidget {
  const FriendManagement({super.key});

  @override
  _FriendManagementState createState() => _FriendManagementState();
}

class _FriendManagementState extends State<FriendManagement> {
  final List<Map<String, dynamic>> friends = [
    {
      'username': 'Fitness Enthusiast',
      'profileImage': 'https://example.com/profile1.jpg',
      'isFriend': true,
    },
    {
      'username': 'Workout Warrior',
      'profileImage': 'https://example.com/profile2.jpg',
      'isFriend': true,
    },
    {
      'username': 'Gym Junkie',
      'profileImage': 'https://example.com/profile3.jpg',
      'isFriend': false,
    },
    {
      'username': 'Running Rebel',
      'profileImage': 'https://example.com/profile4.jpg',
      'isFriend': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImage(
                imageUrl: friend['profileImage'],
                fit: BoxFit.cover,
              ).image,
            ),
            title: Text(
              friend['username'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: friend['isFriend']
                ? ElevatedButton(
                    onPressed: () {
                      // Handle unfriending
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Unfriend'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Handle adding friend
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Add Friend'),
                  ),
          );
        },
      ),
    );
  }
}

extension on CachedNetworkImage {
  get image => null;
}
