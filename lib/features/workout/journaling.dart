import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> journalEntries = [];
  final TextEditingController journalController = TextEditingController();
  final String apiUrl = "http://localhost:3000/api/journal";
  String selectedMood = 'happy';
  final List<String> moodOptions = [
    'happy',
    'sad',
    'neutral',
    'excited',
    'anxious'
  ];
  bool isLoading = true;

  final Map<String, IconData> moodIcons = {
    'happy': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_very_dissatisfied,
    'neutral': Icons.sentiment_neutral,
    'excited': Icons.mood,
    'anxious': Icons.mood_bad,
  };

  final Map<String, Color> moodColors = {
    'happy': Colors.amber,
    'sad': Colors.blue,
    'neutral': Colors.grey,
    'excited': Colors.orange,
    'anxious': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          journalEntries.clear();
          journalEntries.addAll(
              data.map((entry) => JournalEntry.fromJson(entry)).toList());
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> addEntry() async {
    if (journalController.text.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': 2,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'mood': selectedMood,
          'notes': journalController.text,
        }),
      );
      if (response.statusCode == 201) {
        await fetchEntries();
        Navigator.of(context).pop();
        journalController.clear();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateEntry(int id) async {
    if (journalController.text.isEmpty) return;
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': 2,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'mood': selectedMood,
          'notes': journalController.text,
        }),
      );
      if (response.statusCode == 200) {
        await fetchEntries();
        Navigator.of(context).pop();
        journalController.clear();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        setState(() {
          journalEntries.removeWhere((entry) => entry.id == id);
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showEntryDialog({JournalEntry? entry}) {
    if (entry != null) {
      journalController.text = entry.notes;
      selectedMood = entry.mood;
    } else {
      journalController.clear();
      selectedMood = 'happy';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 10,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry == null ? 'New Entry' : 'Edit Entry',
                        style: GoogleFonts.poppins(
                            fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: moodOptions.map((mood) {
                            final isSelected = selectedMood == mood;
                            return GestureDetector(
                              onTap: () => setState(() => selectedMood = mood),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? moodColors[mood]?.withOpacity(0.25)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: moodColors[mood]!
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          )
                                        ]
                                      : [],
                                ),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.3 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    moodIcons[mood],
                                    color: isSelected
                                        ? moodColors[mood]
                                        : Colors.grey[400],
                                    size: 36,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: journalController,
                        maxLines: 5,
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey[900]),
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle:
                              GoogleFonts.poppins(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: moodColors[selectedMood]!, width: 2),
                          ),
                          // Shadow below textfield
                          // Note: InputDecoration doesn't support boxShadow, so wrap TextField with Container if needed
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.grey[600])),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (entry != null) {
                                updateEntry(entry.id);
                              } else {
                                addEntry();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: moodColors[selectedMood],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              entry == null ? 'Add Entry' : 'Update',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => deleteEntry(id),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.amber.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Journal',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: moodColors['happy']),
            )
          : AnimationLimiter(
              child: ListView.builder(
                itemCount: journalEntries.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final entry = journalEntries[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 6,
                          shadowColor: moodColors[entry.mood]?.withOpacity(0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  moodColors[entry.mood]!.withOpacity(0.1),
                                  Colors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: moodColors[entry.mood]
                                            ?.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: moodColors[entry.mood]!
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(moodIcons[entry.mood],
                                          color: moodColors[entry.mood],
                                          size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      DateFormat('MMMM d, yyyy')
                                          .format(DateTime.parse(entry.date)),
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[700],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      color: Colors.grey[700],
                                      onPressed: () =>
                                          showEntryDialog(entry: entry),
                                      tooltip: 'Edit Entry',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.redAccent,
                                      onPressed: () =>
                                          showDeleteConfirmation(entry.id),
                                      tooltip: 'Delete Entry',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  entry.notes,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    height: 1.6,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEntryDialog(),
        backgroundColor: moodColors['happy'],
        elevation: 8,
        highlightElevation: 12,
        icon: const Icon(Icons.add, size: 28),
        label: Text(
          'New Entry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.8,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class JournalEntry {
  final int id;
  final int userId;
  final String date;
  final String mood;
  final String notes;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.notes,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: json['date'],
      mood: json['mood'],
      notes: json['notes'],
    );
  }
}
