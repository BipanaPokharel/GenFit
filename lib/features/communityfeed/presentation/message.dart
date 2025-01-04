import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Messaging extends StatefulWidget {
  const Messaging({super.key});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  final List<Map<String, dynamic>> conversations = [
    {
      'profileImage': 'https://example.com/profile1.jpg',
      'username': 'Fitness Enthusiast',
      'lastMessage': 'Hey, how\'s your workout going?',
      'timestamp': '2 hours ago',
    },
    {
      'profileImage': 'https://example.com/profile2.jpg',
      'username': 'Workout Warrior',
      'lastMessage': 'Did you try the new resistance bands?',
      'timestamp': '1 day ago',
    },
    {
      'profileImage': 'https://example.com/profile3.jpg',
      'username': 'Gym Junkie',
      'lastMessage': 'I\'m going to the gym tonight, wanna join?',
      'timestamp': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(conversation['profileImage']),
              ),
              title: Text(
                conversation['username'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                conversation['lastMessage'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              trailing: Text(
                conversation['timestamp'],
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
