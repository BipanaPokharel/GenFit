import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'like',
      'username': 'Fitness Enthusiast',
      'profileImage': 'https://example.com/profile1.jpg',
      'content': 'liked your post',
      'timestamp': '2 hours ago',
    },
    {
      'type': 'comment',
      'username': 'Workout Warrior',
      'profileImage': 'https://example.com/profile2.jpg',
      'content': 'Great workout! Keep it up.',
      'timestamp': '1 day ago',
    },
    {
      'type': 'follow',
      'username': 'Gym Junkie',
      'profileImage': 'https://example.com/profile3.jpg',
      'content': 'started following you',
      'timestamp': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImage(
                imageUrl: notification['profileImage'],
                fit: BoxFit.cover,
              ).image,
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: notification['username'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${notification['content']}',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ),
            subtitle: Text(notification['timestamp']),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                // Handle clearing notification
              },
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
