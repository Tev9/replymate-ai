import 'package:flutter/material.dart';
import '../widgets/analysis_card.dart';
import '../widgets/recommendation_card.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTone = 'Professional';
  String selectedPlatform = 'WhatsApp';
  List<String> generatedReplies = [];
  bool isLoading = false;
  String writingStyle = '';
  String replyLength = 'Medium';
  String conversationType = '';
  String conversationMood = '';
  String conversationAdvice = '';

  int bestReplyIndex = -1;
  String bestReplyReason = '';

  List<int> replyScores = [];

  final TextEditingController messageController = TextEditingController();
  final AiService aiService = AiService();

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

      conversationType = '';
      conversationMood = '';
      conversationAdvice = '';

      bestReplyIndex = -1;
      bestReplyReason = '';

      replyScores = [];
    });

    final analysis = await aiService.analyzeConversation(
      message: message,
    );

    setState(() {
      conversationType = analysis['type'];
      conversationMood = analysis['mood'];
      conversationAdvice = analysis['advice'];
    });

    final replyData = await aiService.generateReplies(
      message: message,
      tone: selectedTone,
      length: replyLength,
      writingStyle: writingStyle,
      platform: selectedPlatform,
    );

    setState(() {
      generatedReplies = List<String>.from(replyData['replies']);
      replyScores = List<int>.from(replyData['scores'] ?? []);
      bestReplyIndex = replyData['bestReply'] ?? -1;
      bestReplyReason = replyData['reason'] ?? '';
      isLoading = false;
    });
  }

  Future<void> rewriteReply(int index, String instruction) async {
    final oldReply = generatedReplies[index];

    setState(() {
      generatedReplies[index] = 'Rewriting...';
    });

    final newReply = await aiService.rewriteReply(
      reply: oldReply,
      instruction: instruction,
      platform: selectedPlatform,
      writingStyle: writingStyle,
    );

    setState(() {
      generatedReplies[index] = newReply;
    });
  }

  Future<void> showCustomRewriteDialog(int index) async {
    final TextEditingController customController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Rewrite'),
          content: TextField(
            controller: customController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Example: Make it warmer and shorter',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final instruction = customController.text.trim();

                if (instruction.isNotEmpty) {
                  Navigator.pop(context);
                  rewriteReply(index, instruction);
                }
              },
              child: const Text('Rewrite'),
            ),
          ],
        );
      },
    );
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

  Widget platformButton(String title) {
    final bool isSelected = selectedPlatform == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              selectedPlatform = title;
            });
          },
          child: Text(title),
        ),
      ),
    );
  }

  Widget lengthButton(String title) {
    final bool isSelected = replyLength == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              replyLength = title;
            });
          },
          child: Text(title),
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
                  hintText: 'Paste message or conversation...',
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
              const Text(
                'Platform',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  platformButton('WhatsApp'),
                  platformButton('SMS'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  platformButton('Email'),
                  platformButton('LinkedIn'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Reply Length',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  lengthButton('Short'),
                  lengthButton('Medium'),
                  lengthButton('Long'),
                ],
              ),
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
              if (conversationType.isNotEmpty)
                AnalysisCard(
                  type: conversationType,
                  mood: conversationMood,
                  advice: conversationAdvice,
                ),
              const SizedBox(height: 16),
              if (bestReplyIndex >= 0)
                RecommendationCard(
                  bestReplyIndex: bestReplyIndex,
                  reason: bestReplyReason,
                ),
              const SizedBox(height: 16),
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
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Suggestion $index',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (replyScores.length >= index)
                                      Text(
                                        '⭐ ${replyScores[index - 1]}/100',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(reply),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'copy') {
                                      Clipboard.setData(
                                        ClipboardData(text: reply),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Reply copied'),
                                        ),
                                      );
                                    } else if (value == 'custom') {
                                      showCustomRewriteDialog(index - 1);
                                    } else {
                                      rewriteReply(index - 1, value);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'copy',
                                      child: Text('Copy'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it shorter',
                                      child: Text('Shorter'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it longer',
                                      child: Text('Longer'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it funnier',
                                      child: Text('Funny'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it more professional',
                                      child: Text('Professional'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'custom',
                                      child: Text('Custom Rewrite'),
                                    ),
                                  ],
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
