// class ChatScreen extends StatefulWidget {
//   final String chatId;

//   const ChatScreen({Key? key, required this.chatId}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final _channel = WebSocketChannel.connect(Uri.parse('ws://YOUR_BACKEND_URL/ws'));

//   List<String> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     _channel.stream.listen((message) {
//       setState(() {
//         _messages.add(message);
//       });
//       _scrollToBottom();
//     });
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       _channel.sink.add(_messageController.text);
//       _messageController.clear();
//       _scrollToBottom();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_messages[index]),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(hintText: 'Send a message'),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _channel.sink.close();
//     super.dispose();
//   }
// }
