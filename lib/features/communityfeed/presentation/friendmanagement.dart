import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friend Requests',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      home: FriendRequestsScreen(),
    );
  }
}

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final TextEditingController _receiverController = TextEditingController();
  List<dynamic> _pendingRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/friend-requests/pending/1'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pendingRequests = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackBar('Failed to fetch requests');
      }
    } catch (e) {
      _showSnackBar('Network error occurred');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendFriendRequest() async {
    if (_receiverController.text.isEmpty) {
      _showSnackBar('Please enter a user ID');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/friend-requests/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': 1,
          'receiverId': int.parse(_receiverController.text),
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Friend request sent successfully');
        _receiverController.clear();
      } else {
        _showSnackBar('Failed to send request');
      }
    } catch (e) {
      _showSnackBar('Error sending request');
    }
  }

  Future<void> _acceptFriendRequest(int requestId) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/api/friend-requests/accept/$requestId'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Friend request accepted');
        _fetchPendingRequests();
      } else {
        _showSnackBar('Failed to accept request');
      }
    } catch (e) {
      _showSnackBar('Error processing request');
    }
  }

  Future<void> _rejectFriendRequest(int requestId) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/api/friend-requests/reject/$requestId'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Friend request rejected');
        _fetchPendingRequests();
      } else {
        _showSnackBar('Failed to reject request');
      }
    } catch (e) {
      _showSnackBar('Error rejecting request');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPendingRequests,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPendingRequests,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Send Request Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Friend Request',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _receiverController,
                            decoration: const InputDecoration(
                              hintText: 'Enter user ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_add),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _sendFriendRequest,
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pending Requests Section
            Text(
              'Pending Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pendingRequests.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No pending requests',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...(_pendingRequests.map((request) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(request['sender_id'].toString()),
                      ),
                      title: Text('User ${request['sender_id']}'),
                      subtitle: const Text('Wants to be your friend'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text('Accept'),
                            onPressed: () =>
                                _acceptFriendRequest(request['id']),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Reject'),
                            onPressed: () =>
                                _rejectFriendRequest(request['id']),
                          ),
                        ],
                      ),
                    ),
                  ))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _receiverController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MyApp());
}
