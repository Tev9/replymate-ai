import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ReplyMateApp());
}

class ReplyMateApp extends StatelessWidget {
  const ReplyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReplyMate AI',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTone = 'Professional';
  List<String> generatedReplies = [];
  bool isLoading = false;
  String writingStyle = '';

  final TextEditingController messageController = TextEditingController();

  Future<void> generateReply() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        generatedReplies = ['Please enter a message first.'];
      });
      return;
    }

    setState(() {
      isLoading = true;
      generatedReplies = [];
    });

    await Future.delayed(const Duration(seconds: 2));

    switch (selectedTone) {
      case 'Professional':
        generatedReplies = [
          'Thank you for your message regarding "$message". I will get back to you shortly.',
          'I appreciate your message. Let me review it and respond as soon as possible.',
          'Thank you for reaching out. I will follow up with you shortly.',
        ];
        break;

      case 'Friendly':
        generatedReplies = [
          writingStyle.isNotEmpty
        ? 'Based on your style: $writingStyle\n\nReply: Thanks for your message about "$message".'
        : 'Hey! Thanks for your message about "$message". I will get back to you soon 😊',
          'Thanks for reaching out! I will reply as soon as I can.',
          'Got your message 😊 Looking forward to chatting more.',
        ];
        break;

      case 'Funny':
        generatedReplies = [
          'Haha, got your message about "$message". Let me work my magic 😄',
          'Message received! My brain is now processing at full speed 🚀',
          'Hold tight, a legendary reply is loading 😎',
        ];
        break;

      case 'Romantic':
        generatedReplies = [
          'Seeing your message about "$message" made me smile ❤️',
          'Your message brightened my day more than you know 💕',
          'I always enjoy hearing from you ❤️',
        ];
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget toneButton(String title) {
    final bool isSelected = selectedTone == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              selectedTone = title;
            });
          },
          child: Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReplyMate AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Smart replies for every chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Paste or type a message...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                onChanged: (value) {
                  writingStyle = value;
                },
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Optional: Paste examples of how you normally write...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              toneButton('Professional'),
              toneButton('Friendly'),
              toneButton('Funny'),
              toneButton('Romantic'),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: generateReply,
                  child: const Text(
                    'Generate Reply',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Text(
                'AI Suggestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Generating AI reply...'),
                        ],
                      ),
                    )
                  : generatedReplies.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('AI replies will appear here.'),
                          ),
                        )
                      : Column(
                          children:
                              generatedReplies.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final reply = entry.value;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  'Suggestion $index',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(reply),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: reply),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reply copied'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
