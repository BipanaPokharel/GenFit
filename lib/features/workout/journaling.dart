import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> journalEntries = [];
  final TextEditingController journalController = TextEditingController();

  void addEntry() {
    if (journalController.text.isNotEmpty) {
      setState(() {
        journalEntries.add(JournalEntry(
          content: journalController.text,
          date: DateTime.now(),
        ));
        journalController.clear();
      });
    }
  }

  void deleteEntry(int index) {
    setState(() {
      journalEntries.removeAt(index);
    });
  }

  void _showEntryDetails(BuildContext context, JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, y - h:mm a').format(entry.date),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    entry.content,
                    style: GoogleFonts.lato(fontSize: 18),
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
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('My Magical Journal',
                  style: GoogleFonts.dancingScript(fontSize: 26)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.purple, Colors.blue],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Thoughts',
                style: GoogleFonts.merriweather(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverAnimatedList(
            initialItemCount: journalEntries.length,
            itemBuilder: (context, index, animation) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: JournalEntryCard(
                      entry: journalEntries[index],
                      onDelete: () => deleteEntry(index),
                      onTap: () =>
                          _showEntryDetails(context, journalEntries[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(context),
        label: const Text('New Entry'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Entry', style: GoogleFonts.merriweather()),
          content: TextField(
            controller: journalController,
            decoration: const InputDecoration(hintText: "What's on your mind?"),
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                addEntry();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class JournalEntry {
  final String content;
  final DateTime date;

  JournalEntry({required this.content, required this.date});
}

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, y - h:mm a').format(entry.date),
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                entry.content.length > 100
                    ? '${entry.content.substring(0, 100)}...'
                    : entry.content,
                style: GoogleFonts.merriweather(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
