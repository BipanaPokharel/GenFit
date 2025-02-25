import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int receiverId;

  const ChatScreen({Key? key, required this.userId, required this.receiverId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    // Initialize the socket connection
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect to the socket server
    socket.connect();

    // Listen for connection event
    socket.on('connect', (_) {
      setState(() {
        isConnected = true;
      });

      // Join as the current user (using server's 'join' event)
      socket.emit('join', widget.userId);

      print('Connected to socket server: ${socket.id}');
    });

    // Listen for disconnect event
    socket.on('disconnect', (_) {
      setState(() {
        isConnected = false;
      });
      print('Disconnected from socket server');
    });

    // Listen for incoming messages
    socket.on('receive_message', (data) {
      print('Message received: $data');
      if (data['senderId'] == widget.receiverId) {
        setState(() {
          messages.add({
            'senderId': data['senderId'],
            'message': data['message'],
            'timestamp': data['timestamp'],
          });
        });
      }
    });

    // Listen for message sent confirmation
    socket.on('message_sent', (data) {
      print('Message sent confirmation: $data');
    });

    // Listen for error messages
    socket.on('error_message', (data) {
      print('Error received: $data');
      _showErrorMessage(data['error']);
    });

    // Fetch chat history from the REST API
    _fetchChatHistory();
  }

  @override
  void dispose() {
    // Disconnect the socket when the screen is disposed
    socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text.trim();

      // Using the server's expected event structure
      socket.emit('send_message', {
        'senderId': widget.userId,
        'receiverId': widget.receiverId,
        'message': message,
      });

      // Optimistically add to UI (will be confirmed by server)
      setState(() {
        messages.add({
          'senderId': widget.userId,
          'message': message,
          'timestamp': DateTime.now().toString(),
        });
      });

      _controller.clear();
    }
  }

  // Fetch chat history using REST API
  Future<void> _fetchChatHistory() async {
    // Updated to match the server's actual route pattern
    final url =
        'http://localhost:3000/api/chat/${widget.userId}/${widget.receiverId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> chatData = json.decode(response.body);
        setState(() {
          messages = chatData
              .map((msg) => {
                    'senderId': msg['sender_id'],
                    'message': msg['message'],
                    'timestamp': msg['created_at'],
                  })
              .toList();
        });
      } else {
        // Handle error if fetching fails
        _showErrorMessage(
            'Failed to load chat history: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorMessage('Error fetching chat history: $error');
    }
  }

  // Show error message dialog
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Format the timestamp to a human-readable format
  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User ${widget.receiverId}'),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              isConnected ? Icons.circle : Icons.circle_outlined,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      bool isSentByUser = message['senderId'] == widget.userId;
                      return ListTile(
                        title: Align(
                          alignment: isSentByUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSentByUser
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message['message'],
                              style: TextStyle(
                                  color: isSentByUser
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        subtitle: Align(
                          alignment: isSentByUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            _formatTimestamp(message['timestamp']),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
